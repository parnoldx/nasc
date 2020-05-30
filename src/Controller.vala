/*
 * Copyright (c) 2015 Peter Arnold
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class NascSheet : Granite.Widgets.SourceList.Item {
    public string content;
    public int index;

    public NascSheet (string name, string content) {
        this.editable = true;
        this.name = name;
        this.content = content;
        this.icon = new ThemedIcon ("document");
        this.edited.connect ((s) => {
            this.name = s;
        });
    }
}

public class Controller : Object {
    public InputView input { get; private set; }
    public ResultView results { get; private set; }
    public NascSettings settings { get; private set; }
    private Regex digit_regex;
    public Calculator calculator;
    private int override_line = -1;
    private bool calc_lock = false;
    private Gee.ArrayList<string> enable_calc;
    private Gee.ArrayList<NascSheet>? sheet_list;
    public NascSheet actual_sheet { get; private set; }
    private Gee.LinkedList<NascSheet> removal_list;

    private string sheet_base = Path.build_filename (
                                Environment.get_user_data_dir(),
                                NascSettings.sheet_dir);
    private string sheet_path;

    private string _sheets;
    public string sheets_file {
        get {
            var text = new StringBuilder ();

            try {
                var file = File.new_for_path (sheet_path);

                if (file.query_exists ()) {
                    var dis = new DataInputStream (file.read ());
                    string line = null;

                    while ((line = dis.read_line ()) != null) {
                        text.append (line);
                    }
                }
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }

            _sheets = text.str;

            return _sheets;
        }
        set {
            try {
                var file = File.new_for_path (sheet_path);

                if (file.query_exists ()) {
                    file.delete ();
                }

                var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
                dos.put_string (value);
                dos.close ();
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
        }
    }

    public signal void tutorial ();
    public signal void periodic ();
    private bool skip_update = false;

    public Controller (InputView input, ResultView results) {
        this.sheet_path = Path.build_filename (this.sheet_base, "nasc.sheets");
        this.enable_calc = input.operators;
        this.removal_list = new Gee.LinkedList<NascSheet> ();
        /* add " to " to enable_calc list to allow variable to other unit conversion */
        enable_calc.add (" to ");

        try {
            digit_regex = new Regex ("\\d", RegexCompileFlags.OPTIMIZE);
        } catch (GLib.RegexError ex) {
        }

        this.input = input;
        this.results = results;
        this.input.changed_line.connect ((line, total_lines, text) => {
            update_results.begin (line, total_lines, text);
        });
        this.input.line_added.connect ((line, count) => {
            results.add_line (line, count);
        });
        this.input.line_removed.connect ((line, count) => {
            results.remove_line (line, count);
        });
        this.input.insert_result.connect ((line) => {
            if (line >= results.result_list.size) {
                return;
            }

            var res = results.result_list.get (line);

            if (res == null) {
                return;
            }

            input.insert_variable (res);
        });
        this.input.cursor_line_change.connect ((line) => {
            results.update (line, true);
        });
        this.input.copy_result_to_clipboard.connect ((line) => {
            var res = results.result_list.get (line);
            if (res == null) {
                return;
            }
            Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD).set_text (res.value, -1);
        });
        this.results.insert_variable.connect ((res) => {
            input.skip_change = true;
            input.insert_variable (res);
            input.skip_change = false;
        });
        this.calculator = new Calculator ();
        this.input.get_functions.connect(()=>{
            var list = new Gee.ArrayList<NascFunction>();
            list.add_all(calculator.functions);
            list.add_all(calculator.advanced_functions);
            return list;
        });

        debug ("loading sheets");
        /* ensure nasc.sheets exists */
        var file = File.new_for_path (sheet_path);

        if (!file.query_exists ()) {
            try {
                var dir = File.new_for_path (sheet_base);

                if (!dir.query_exists ()) {
                    dir.make_directory ();
                }
            }  catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
        }

        debug ("getting sheets");
        get_sheets ();

        debug ("set last sheet");
        if(sheet_list.size > 0) {
            set_sheet (sheet_list.get (0));
        }
    }

    public string get_content () {
        return input.get_replaced_content ();
    }

    public Gee.LinkedList<NascSheet> get_removal_list () {
        return removal_list;
    }

    async void update_results (int line, int total_lines, string text) {
        if (skip_update) {
            return;
        }
        /* make sure only one calc cycle is present at a time */
        if (calc_lock) {
            calculator.cancel.cancel ();
        }

        while (calc_lock) {
            GLib.Timeout.add (10, () => {
                update_results.callback ();

                return false;
            });
            yield;
        }

        calc_lock = true;
        calculator.cancel.reset ();
        string[] line_texts = text.split ("\n");
        int index = 0;
        total_lines = results.result_list.size;

        for (int i = line; i < total_lines; i++) {
            var line_text = line_texts[index];
            if (line_text != null && check_for_calculation (line_text)) {
                if (calculator.cancel.is_cancelled ()) {
                    calc_lock = false;
                    return;
                }
                string result = "";
                calculator.calculate_store_variable.begin (
                    line_text, NascSettings.variable_names + "%d".printf (i),
                    (obj, res) => {
                    result = calculator.calculate_store_variable.end (res);
                    update_results.callback ();
                });
                uint spinner_handle = 0;
                spinner_handle = GLib.Timeout.add (80, () => {
                    spinner_handle = 0;
                    results.show_spinner (i);

                    return false;
                });
                yield;

                if (spinner_handle > 0) {
                    GLib.Source.remove (spinner_handle);
                } else {
                    results.hide_spinner ();
                }

                if (calculator.cancel.is_cancelled ()) {
                    calc_lock = false;
                    return;
                }

                results.set_line (i, result);
            } else {
                results.set_line (i, "");
            }

            index++;
        }

        if (override_line > 0) {
            line = override_line;
            override_line = -1;
        }

        results.update (line);
        actual_sheet.content = input.get_replaced_content ();
        calc_lock = false;
    }

    public void set_sheet (NascSheet sheet) {
        actual_sheet = sheet;
        var content = sheet.content;

        if (content == null) {
            content = "";
        }
        skip_update = true;
        input.buffer.text = content;
        //input.process_new_content ();
        Gtk.TextIter iter = Gtk.TextIter ();
        input.source_view.buffer.get_iter_at_offset (out iter, input.source_view.buffer.cursor_position);
        override_line = iter.get_line ();
        skip_update = false;
        input.process_new_content ();
    }

    public void set_content (string content) {
        input.buffer.text = content;
        input.process_new_content ();
        Gtk.TextIter iter = Gtk.TextIter ();
        input.source_view.buffer.get_iter_at_offset (out iter, input.source_view.buffer.cursor_position);
        override_line = iter.get_line ();
    }

    public Gee.ArrayList<NascSheet> get_sheets () {
        if (sheet_list == null) {
            sheet_list = new Gee.ArrayList<NascSheet> ();
            string[] sheets_split = sheets_file.split (NascSettings.sheet_split_char);
            foreach (string sheet in sheets_split) {
                string[] content = sheet.split (NascSettings.name_split_char);
                sheet_list.add (new NascSheet (content[0], content[1].replace ("\\n", "\n")));
            }
            if (sheet_list.size == 0){
                sheet_list.add (new NascSheet ("sheet",""));
            }
        }

        return sheet_list;
    }

    public NascSheet add_sheet () {
        actual_sheet = new NascSheet ("sheet", "");
        sheet_list.add (actual_sheet);
        input.buffer.text = "";

        return actual_sheet;
    }

    public void remove_sheet (NascSheet sheet) {
        var index = sheet_list.index_of (sheet);
        sheet.index = index;
        removal_list.offer_tail (sheet);
        sheet_list.remove (sheet);

        if (index >= sheet_list.size) {
            index = sheet_list.size - 1;
        }

        actual_sheet = sheet_list.get (index);
    }

    public void undo_removal () {
        if (removal_list.size > 0) {
            var sheet = removal_list.poll_tail ();

            if (sheet_list.size <= sheet.index) {
                sheet_list.add (sheet);
            } else {
                sheet_list.insert (sheet.index, sheet);
            }
        }
    }

    public void store_sheet_content () {
        var text = new StringBuilder ();

        foreach (var sheet in sheet_list) {
            text.append (sheet.name);
            text.append (NascSettings.name_split_char);
            text.append (sheet.content.replace ("\n", "\\n"));

            if (sheet_list.index_of (sheet) != sheet_list.size - 1) {
                text.append (NascSettings.sheet_split_char);
            }

            if (sheet == actual_sheet) {
                NascSettings.get_instance ().open_sheet = sheet_list.index_of (sheet);
            }
        }

        sheets_file = text.str;
    }

    /*
     * in this fuction the line is checked if it should be send to calculation
     * Till now it checks on digits, operators, functions and variables.
     * When something is present in the line it will be send to calculation.
     * TODO add negativ cases?! do it better!
     */
    private bool check_for_calculation (string input) {
        if (input == null || input == "") {
            return false;
        } 
        if (input.contains ("http://")) {
            return false;
        } else if (digit_regex.match (input)) {
            /* cases when a digit is present and it should not be calculated? */
            return true;
        } else {
            foreach (var op in this.enable_calc) {
                if (input.contains (op)) {
                    return true;
                }
            }

            /* check on use of functions */
            foreach (var fct in calculator.functions) {
                if (input.contains ("%s(".printf (fct.name))) {
                    return true;
                }
            }

            /* check on use of variables */
            foreach (var v in calculator.variables) {
                if (v.name.length > 3 && input.contains (v.name)) {
                    return true;
                }
            }
            Gee.List<string> defined_variables = calculator.defined_variables;
            foreach (var v in defined_variables){
                if (input.has_prefix (v)){
                    return true;
                }
            }

            if (input == "tutorial()") {
                tutorial ();
            } else if (input ==  "atom()") {
                periodic ();
            } 

            return false;
        }
    }

    public string get_export_text () {
        var input_text = get_content ().split ("\n");
        string[] result_text = {};

        foreach (var rl in this.results.result_list) {
            result_text += rl.value;
        }

        int longest_line = 80;
        var sb = new StringBuilder ();

        for (int i = 0; i < input_text.length; i++) {
            sb.append (input_text[i]);
            int actual_length = 0;
            unichar c;

            for (int k = 0; input_text[i].get_next_char (ref k, out c);) {
                actual_length++;
            }

            for (int j = actual_length; j < longest_line; j++) {
                sb.append (" ");
            }

            sb.append ("| ");
            sb.append (result_text[i]);
            sb.append ("\n");
        }

        return sb.str;
    }

        

}