/*
 * Copyright (c) 2016 Peter Arnold
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

public class NascElement : Object {
    public int index;
    public string name;
    public string title;
    public string category;
    public string desc;
}

public class NascFunction : NascElement {
    public string args;
    public string args_list;

    public NascFunction (int index, string category) {
        this.index = index;
        this.name = QalculateNasc.get_function_name (index);
        this.title = QalculateNasc.get_function_title (index);
        this.category = category;
        this.desc = QalculateNasc.get_function_description (index);
        this.args = QalculateNasc.get_function_arguments (index);
        this.args_list = QalculateNasc.get_function_arguments_list (index);
    }

    public NascFunction.nasc (string name, string title, string desc) {
        this.index = -1;
        this.name = name;
        this.title = title;
        this.category = "NaSC";
        this.desc = desc;
        this.args = "";
    }
}

public class NascVariabel : NascElement {
    public NascVariabel (int index, string category) {
        this.name = QalculateNasc.get_variable_name (index);
        this.title = QalculateNasc.get_variable_title (index);
        this.category = category;
        this.desc = build_desc ();
    }

    private string build_desc () {
        return category;
    }
}

internal class Calculation : GLib.Object {
    public string input;
    public string output;
    public string variable;
    public bool save_variable = true;

    public Calculation (string input) {
        this.input = input;
        this.save_variable = false;
    }

    public Calculation.with_variable (string input, string variable) {
        this.input = input;
        this.variable = variable;
    }
}

internal class CalculatorThread {
    public Gee.List<NascFunction> functions { get; private set; }
    public Gee.List<NascFunction> advanced_functions { get; private set; }
    public Gee.List<NascVariabel> variables { get; private set; }

    public string currency_update_url { get; private set; }
    public string currency_update_filename { get; private set; }

    private Regex digit_regex;
    private Regex pretty_regex;
    private const unichar superscript_digits[] = { '⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹' };

    public AsyncQueue<Calculation> calculations { get; private set; }
    public AsyncQueue<Calculation> results { get; private set; }

    public SourceFunc callback;
    private Cancellable cancel;

    public CalculatorThread (Cancellable cancel) {
        this.cancel = cancel;
        functions = new Gee.ArrayList<NascFunction> ();
        advanced_functions = new Gee.ArrayList<NascFunction> ();
        variables = new Gee.ArrayList<NascVariabel> ();
        calculations = new AsyncQueue<Calculation> ();
        results = new AsyncQueue<Calculation> ();

        try {
            digit_regex = new Regex ("\\d", RegexCompileFlags.OPTIMIZE);
            pretty_regex = new Regex ("E(\\d|-)", RegexCompileFlags.OPTIMIZE);
        } catch (GLib.RegexError ex) {
        }
    }

    ~CalculatorThread () {
        QalculateNasc.delete_calculator ();
    }

    public void * thread_func () {
        QalculateNasc.new_calculator ();
        currency_update_url = QalculateNasc.get_exchange_rates_url ();
        currency_update_filename = QalculateNasc.get_exchange_rates_filename ();
        load_functions.begin ();
        load_variables.begin ();
        cancel.cancelled.connect (() => {
            abort ();
        });

        while (true) {
            Calculation calc = calculations.pop ();

            if (calc.save_variable) {
                calc.output = post_string (QalculateNasc.calculate_store_variable (
                                               prepare_string (calc.input), calc.variable));
                results.push (calc);
                Idle.add ((owned) callback);
            } else {
                calc.output = post_string (QalculateNasc.calculate (
                                               prepare_string (calc.input)));
                results.push (calc);
            }
        }
    }

    private void abort () {
        QalculateNasc.abort ();
    }

    /*
     * private void clear () {
     *     QalculateNasc.clear_variables();
     * }
     */

    private async void load_functions () {
        for (int i = 0; i < QalculateNasc.get_function_size (); i++) {
            var category = QalculateNasc.get_function_category (i);

            if (category == "") {
                continue;
            }

            if (category == "Utilities" || category == "Trigonometry" || category == "Step Functions"
                || category.contains ("Statistics/") || category.contains ("Economics/") || category.contains ("Geometry/")
                || category == "Combinatorics" || category == "Logical" || category == "Date & Time"
                || category == "Miscellaneous" || category == "Number Theory/Arithmetics" || category == "Number Theory/Integers"
                || category == "Number Theory/Number Bases" || category == "Number Theory/Polynomials") {
                advanced_functions.add (new NascFunction (i, category));
                continue;
            } else if (category == "Exponents & Logarithms") {
                var func_name = QalculateNasc.get_function_name (i);

                if (func_name == "lambertw" || func_name == "cis" || func_name == "sqrtpi" || func_name == "pow"
                    || func_name == "exp10" || func_name == "exp2") {
                    advanced_functions.add (new NascFunction (i, category));
                    continue;
                }
            } else if (category == "Matrices & Vectors") {
                var func_name = QalculateNasc.get_function_name (i);

                if (func_name == "export" || func_name == "genvector" || func_name == "load" || func_name == "permanent"
                    || func_name == "area" || func_name == "matrix2vector") {
                    advanced_functions.add (new NascFunction (i, category));
                    continue;
                }
            } else if (category == "Calculus/Named Integrals"){
                var func_name = QalculateNasc.get_function_name (i);

                if (func_name == "fresnelc" || func_name == "fresnels" ) {
                    advanced_functions.add (new NascFunction (i, category));
                    continue;
                }
            }

            functions.add (new NascFunction (i, category));
        }

        functions.sort ((a, b) => a.title.collate (b.title));
    }

    private async void load_variables () {
        for (int i = 0; i < QalculateNasc.get_variable_size (); i++) {
            var category = QalculateNasc.get_variable_category (i);

            if (category == "" || category == "Temporary" || category == "Unknowns" || category == "Large Numbers" ||
                category == "Small Numbers") {
                continue;
            }

            variables.add (new NascVariabel (i, category));
        }

        variables.sort ((a, b) => a.title.collate (b.title));
    }

    /* string functions */

    private string prepare_string (string input) {
        string return_str = input;
        /* in case of a simple assignment like a := 5 where on the left side is just one word you can also use = */
        string[] split = return_str.split ("=");

        if (split.length == 2 && split[0].chomp ().split (" ").length == 1) {
            return_str = return_str.replace ("=", ":=");
        }

        // allow comments at the end of a line
        string[] split2 = return_str.split ("//");
        if(split2.length == 2){
            return_str = split2[0];
        }


        /* to enable currency signs */
        return_str = return_str.replace ("$", "USD").replace ("€", "EUR").replace ("£", "GBP").replace ("¥", "JPY");

        return return_str;
    }

    private string post_string (string result) {
        string return_str = result;
        return_str = return_str.replace ("USD", "$").replace ("EUR", "€").replace ("GBP", "£").replace ("JPY", "¥");
        return_str = return_str.replace (" °", "°");
        return_str = pretty_print (return_str);

        return return_str;
    }

    private string pretty_print (string result) {
        var pretty_result = result;

        if (!pretty_regex.match (pretty_result) || result.has_prefix ("[")) {
            return pretty_print2 (pretty_result);
        }

        bool minus = false;
        int index = 1;

        if (pretty_result.substring (pretty_result.last_index_of ("E") + 1, 1) == "-") {
            minus = true;
            index = 2;
        }

        var sb = new GLib.StringBuilder ();
        unichar c;
        bool ex_end = false;
        bool active = false;

        for (int i = 0; result.substring (pretty_result.last_index_of ("E") + index).
              get_next_char (ref i, out c);) {
            if (ex_end || !digit_regex.match (c.to_string ())) {
                if (c.to_string () == "^") {
                    active = true;
                    continue;
                }

                if (active) {
                    if (digit_regex.match (c.to_string ())) {
                        sb.append_unichar (superscript_digits[int.parse (c.to_string ())]);
                        continue;
                    } else {
                        active = false;
                    }
                }

                sb.append_unichar (c);
                ex_end = true;
            } else {
                sb.append_unichar (superscript_digits[int.parse (c.to_string ())]);
            }
        }

        string exponent = sb.str;

        if (minus) {
            exponent = "⁻" + exponent;
        }

        return pretty_result.substring (0, pretty_result.last_index_of ("E")) + " x 10" + exponent;
    }

    private string pretty_print2 (string str) {
        var sb = new GLib.StringBuilder ();
        bool active = false;
        unichar c;

        for (int i = 0; str.get_next_char (ref i, out c);) {
            if (active) {
                if (digit_regex.match (c.to_string ())) {
                    sb.append_unichar (superscript_digits[int.parse (c.to_string ())]);
                    continue;
                } else {
                    active = false;
                }
            }

            if (c.to_string () == "^") {
                active = true;
                int ii = i;
                str.get_next_char (ref ii, out c);

                if (digit_regex.match (c.to_string ())) {
                    continue;
                }
            }

            sb.append_unichar (c);
        }

        return sb.str;
    }
}

internal class UpdateThread {
    private string file;
    private string url;

    public UpdateThread (string file, string url) {
        this.file = file;
        this.url = url;
    }

    public bool thread_func () {
        var update_file = File.new_for_path (file);

        if (update_file.query_exists ()) {
            Posix.Stat stat;
            Posix.lstat (file, out stat);
            var mod = stat.st_mtime;
            var now = new DateTime.now_local ().to_unix ();
            var delta = now - mod;

            /* delta is bigger than 2 days -> update */
            if (delta > (172800)) { /* in 48h in s */
                try {
                    update_file.@delete ();
                } catch (Error e) {
                    critical ("Error: %s\n", e.message);
                }
            }
        }

        if (!update_file.query_exists ()) {
            /* update it */
            try {
                var target_dir = File.new_for_path (Path.get_dirname (file));
                if(!target_dir.query_exists ())
                    target_dir.make_directory_with_parents ();

                debug ("update exchange rates file");
                var exch_file = File.new_for_uri (url);
                exch_file.copy (update_file, FileCopyFlags.NONE);

                return true;
            } catch (Error e) {
                critical ("Error: %s\n", e.message);
            }
        }

        return false;
    }
}

public class Calculator : Object {
    public Gee.List<NascFunction> functions {
        get {
            return calc_thread.functions;
        }
        private set {
            /* not needed, redirect */
        }
    }
    public Gee.List<NascFunction> advanced_functions {
        get {
            return calc_thread.advanced_functions;
        }
        private set {
            /* not needed, redirect */
        }
    }
    public Gee.List<NascVariabel> variables {
        get {
            return calc_thread.variables;
        }
        private set {
            /* not needed, redirect */
        }
    }

    public Cancellable cancel { get; private set; }

    private CalculatorThread calc_thread;
    private UpdateThread update_thread;
    private Thread<void*> thread;
    private Thread<bool> thread2;
    public Calculator () {
        /* calculation thread, will run all the time */
        this.cancel = new Cancellable ();
        calc_thread = new CalculatorThread (cancel);

        try {
            thread = new Thread<void*> .try ("calc_thread", calc_thread.thread_func);
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }

        Timeout.add (500, () => {
            /* currency rate update thread */
            update_thread = new UpdateThread (calc_thread.currency_update_filename, calc_thread.currency_update_url);

            try {
                thread2 = new Thread<bool> .try ("currency_update_thread", update_thread.thread_func);
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }

            return false;
        });
    }

    public Gee.TreeMap<string, Gee.ArrayList<NascFunction> > category_functions () {
        var map = new Gee.TreeMap<string, Gee.ArrayList<NascFunction> > ();

        foreach (var fe in functions) {
            var id = fe.category;

            /* group some categories together */
            if (!NascSettings.get_instance ().advanced_mode && id.has_prefix ("Number Theory/")) {
                id = "Number Theory";
            }

            var list = map.get (id);

            if (list == null) {
                list = new Gee.ArrayList<NascFunction> ();
            }

            list.add (fe);
            map.set (id, list);
        }

        if (NascSettings.get_instance ().advanced_mode) {
            foreach (var fe in advanced_functions) {
                var id = fe.category;
                var list = map.get (id);

                if (list == null) {
                    list = new Gee.ArrayList<NascFunction> ();
                }

                list.add (fe);
                map.set (id, list);
            }
        }

        /* map.sort((a, b) => a.name.collate(b.name)); */
        return map;
    }

    public string calculate (string input) {
        calc_thread.calculations.push (new Calculation (input));

        return calc_thread.results.pop ().output;
    }

    public async string calculate_store_variable (string input, string variable) {
        calc_thread.callback = calculate_store_variable.callback;
        calc_thread.calculations.push (new Calculation.with_variable (input, variable));
        yield;

        return calc_thread.results.pop ().output;
    }
}
