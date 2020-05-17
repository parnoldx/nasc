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

internal class HelpCellRenderer : Gtk.CellRendererText {
    public bool category;

    public override void render (Cairo.Context ctx, Gtk.Widget widget,
                                 Gdk.Rectangle background_area,
                                 Gdk.Rectangle cell_area,
                                 Gtk.CellRendererState flags) {
        if (category) {
            ctx.set_source_rgba (0.82353, 0.82353, 0.82353, 1);
            ctx.rectangle (cell_area.x - 5, cell_area.y, cell_area.width + 10, cell_area.height);
            ctx.fill ();
            ctx.set_line_width (1);
            ctx.set_source_rgba (0.68234, 0.68234, 0.68234, 1);
            ctx.rectangle (cell_area.x - 5, cell_area.y, cell_area.width + 10, cell_area.height);
            ctx.stroke ();
        }

        base.render (ctx, widget, background_area, cell_area, flags);
    }
}

public class HelpBox : Gtk.Box {
    private Controller controller;
    private Gtk.SearchEntry search_entry;
    private Gtk.TreeView list;
    private Gtk.ListStore list_store;
    private Gtk.Stack detail_stack;
    private Gtk.Label headline;
    private Gtk.Label name_label;
    private Gtk.Label arg_label;
    private Gtk.Label arg_list_label;
    private Gtk.Label desc_label;
    private Gtk.Separator seper;

    public signal void close_help ();

    public HelpBox (Controller controller) {
        this.controller = controller;
        list_store = new Gtk.ListStore (6, typeof (string), typeof (string),
                                        typeof (string), typeof (string), typeof (string), typeof (string));
        set_orientation (Gtk.Orientation.VERTICAL);
        search_entry = new Gtk.SearchEntry ();
        search_entry.margin = 10;
        search_entry.hexpand = true;
        pack_start (search_entry, false, true);
        pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true);
        var pane = new Gtk.Paned (Gtk.Orientation.VERTICAL);
        var scroll = new Gtk.ScrolledWindow (null, null);
        scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

        list = new Gtk.TreeView ();
        HelpCellRenderer cell = new HelpCellRenderer ();
        cell.xpad = 10;
        var column = new Gtk.TreeViewColumn.with_attributes (_("Name"), cell);
        column.set_cell_data_func (cell, cell_layout);
        list.insert_column (column, -1);
        list.set_activate_on_single_click (true);
        list.set_enable_search (true);
        list.set_search_column (1);
        /* list.set_search_equal_func (); */
        list.set_search_entry (search_entry);
        list.headers_visible = false;
        scroll.add (list);
        /* init elements of detail box */
        detail_stack = new Gtk.Stack ();
        var detail_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        headline = new Gtk.Label ("");
        headline.margin_top = 10;
        headline.margin_left = 10;
        headline.halign = Gtk.Align.START;
        headline.set_alignment (0, 0);
        headline.use_markup = true;
        headline.wrap = true;
        headline.justify = Gtk.Justification.LEFT;

        name_label = new Gtk.Label ("");
        name_label.margin_top = 8;
        name_label.margin_left = 10;
        name_label.halign = Gtk.Align.START;
        name_label.use_markup = true;
        name_label.wrap = true;
        name_label.set_alignment (0, 0);

        arg_label = new Gtk.Label ("");
        arg_label.margin_top = 8;
        arg_label.margin_left = 10;
        arg_label.halign = Gtk.Align.START;
        arg_label.use_markup = true;
        arg_label.wrap = true;

        arg_list_label = new Gtk.Label ("");
        arg_list_label.margin_top = 10;
        arg_list_label.margin_left = 20;
        arg_list_label.halign = Gtk.Align.START;
        arg_list_label.use_markup = true;
        arg_list_label.wrap = true;
        arg_list_label.set_alignment (0, 0);

        desc_label = new Gtk.Label ("");
        desc_label.margin_top = 10;
        desc_label.margin_left = 10;
        desc_label.halign = Gtk.Align.START;
        desc_label.use_markup = true;
        desc_label.wrap = true;
        desc_label.justify = Gtk.Justification.LEFT;
        desc_label.set_alignment (0, 0);

        seper = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        seper.no_show_all = true;
        seper.margin_top = 6;

        detail_box.pack_start (headline, false, true);
        detail_box.pack_start (name_label, false, true);
        detail_box.pack_start (arg_label, false, true);
        detail_box.pack_start (arg_list_label, false, true);
        detail_box.pack_start (seper, false, true);
        detail_box.pack_start (desc_label, false, true);

        var amath_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        var a_headline = new Gtk.Label ("");
        a_headline.margin_top = 10;
        a_headline.margin_left = 10;
        a_headline.halign = Gtk.Align.START;
        a_headline.set_alignment (0, 0);
        a_headline.use_markup = true;
        a_headline.wrap = true;
        a_headline.justify = Gtk.Justification.LEFT;
        a_headline.set_markup ("<big><big>Advanced Math</big></big>");

        var a_desc_label = new Gtk.Label ("");
        a_desc_label.margin_top = 10;
        a_desc_label.margin_left = 10;
        a_desc_label.halign = Gtk.Align.START;
        a_desc_label.use_markup = true;
        a_desc_label.wrap = true;
        a_desc_label.justify = Gtk.Justification.LEFT;
        a_desc_label.set_alignment (0, 0);
        a_desc_label.set_markup ("<small>Shows advanced math functions in the help</small>");

        var a_switch = new Gtk.Switch ();
        a_switch.margin_top = 10;
        a_switch.margin_left = 10;
        a_switch.halign = Gtk.Align.START;
        a_switch.set_active (NascSettings.get_instance ().advanced_mode);
        a_switch.notify["active"].connect (() => {
            NascSettings.get_instance ().advanced_mode = !NascSettings.get_instance ().advanced_mode;
            reload_list.begin ();
        });

        amath_box.pack_start (a_headline, false, true);
        amath_box.pack_start (a_desc_label, false, true);
        amath_box.pack_start (a_switch, false, true);
        /* finished init */

        detail_stack.add_named (detail_box, "detail");
        detail_stack.add_named (amath_box, "amath");
        pane.pack1 (scroll, true, false);
        pane.pack2 (detail_stack, true, false);
        pane.set_position (350);
        pack_start (pane, true, true);

        search_entry.search_changed.connect (on_search_change);
        load_list.begin ();

        list.key_press_event.connect ((e) => {
            if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                if (e.keyval == Gdk.Key.h) {
                    close_help ();

                    return true;
                }
            }

            search_entry.key_press_event (e);

            return false;
        });
        list.button_press_event.connect ((e) => {
            if (e.type == Gdk.EventType.@2BUTTON_PRESS) {
                Gtk.TreeIter iter;
                Value val;
                list.get_selection ().get_selected (null, out iter);
                list_store.get_value (iter, 0, out val);
                var name = val.get_string ();

                if (name == "") {
                    return false;
                }

                list_store.get_value (iter, 2, out val);
                var category = val.get_string ();

                if (!(category == "Variables")) {
                    name += "(";
                }

                controller.input.source_view.buffer.insert_at_cursor (name, -1);
                controller.input.source_view.grab_focus ();
            }

            return false;
        });
    }

    public void search_focus () {
        list.grab_focus ();
    }

    public void cell_layout (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
        Value name_val;
        model.get_value (iter, 1, out name_val);
        string name = name_val.get_string ();
        Value cat_val;
        model.get_value (iter, 2, out cat_val);
        string cat = cat_val.get_string ();

        (cell as Gtk.CellRendererText).text = name;

        /* format the double into a string */
        if (name == cat) {
            (cell as HelpCellRenderer).category = true;
        } else {
            (cell as HelpCellRenderer).category = false;
        }
    }

    private void on_search_change () {
        if (search_entry.get_text () == "") {
            headline.set_text ("");
            name_label.set_text ("");
            arg_label.set_text ("");
            arg_list_label.set_text ("");
            desc_label.set_text ("");
            seper.hide ();

            return;
        }

        list.grab_focus ();
        Gtk.TreeIter iter;
        Gtk.TreeModel model;
        list.get_selection ().get_selected (out model, out iter);
        show_selection (iter);
    }

    private void on_selection () {
        Gtk.TreeIter iter;
        list.get_selection ().get_selected (null, out iter);
        show_selection (iter);
    }

    private void show_selection (Gtk.TreeIter iter) {
        if (iter.stamp == 0) {
            return;
        }

        Value val;
        list_store.get_value (iter, 1, out val);

        if (val.get_string () == null) {
            headline.set_text ("");
            name_label.set_text ("");
            arg_label.set_text ("");
            arg_list_label.set_text ("");
            desc_label.set_text ("");
            seper.hide ();

            return;
        } else if (val.get_string () == "Advanced Math") {
            detail_stack.set_visible_child_name ("amath");

            return;
        }

        detail_stack.set_visible_child_name ("detail");
        headline.set_markup ("<big><big>%s</big></big>".printf (GLib.Markup.escape_text (val.get_string ())));
        list_store.get_value (iter, 0, out val);
        var name = val.get_string ();
        list_store.get_value (iter, 2, out val);
        var category = val.get_string ();
        list_store.get_value (iter, 5, out val);

        if (name == val.get_string ()) {
            name_label.set_text ("");
            arg_label.set_text ("");
            arg_list_label.set_text ("");
            desc_label.set_text ("");
            seper.hide ();

            return;
        }

        if (category == "Variables") {
            name_label.set_markup ("<small><b>%s</b></small>".printf (GLib.Markup.escape_text(name)));
            list_store.get_value (iter, 3, out val);
            arg_label.set_markup ("<small>%s</small>".printf (GLib.Markup.escape_text(val.get_string ())));
            arg_list_label.set_text ("");
            desc_label.set_text ("");
            seper.hide ();
        } else if (category == "NaSC") {
            if (name != "") {
                name_label.set_markup ("<small><b>%s</b>()</small>".printf (name));
                list_store.get_value (iter, 3, out val);
                arg_label.set_markup ("<small>%s</small>".printf (val.get_string ()));
            } else {
                list_store.get_value (iter, 3, out val);
                name = val.get_string ();
                name_label.set_markup ("<small>%s</small>".printf (name));
                arg_label.set_text ("");
            }

            arg_list_label.set_text ("");
            seper.hide ();
            desc_label.set_text ("");
        } else {
            list_store.get_value (iter, 4, out val);
            name_label.set_markup ("<small><b>%s</b>(%s)</small>".printf (GLib.Markup.escape_text(name), GLib.Markup.escape_text(val.get_string ())));
            list_store.get_value (iter, 5, out val);
            arg_label.set_markup ("<small><b>Arguments</b></small>");
            arg_list_label.set_markup ("<small>%s</small>".printf (GLib.Markup.escape_text(val.get_string ())));
            list_store.get_value (iter, 3, out val);

            if (val.get_string () != "") {
                seper.no_show_all = false;
                seper.show ();
                desc_label.set_markup ("<small>%s</small>".printf (GLib.Markup.escape_text(val.get_string ())));
            } else {
                seper.hide ();
                desc_label.set_text ("");
            }
        }
    }

    private async void load_list () {
        Gtk.TreeIter iter;

        /* wait till the calculator thread has loaded the functions */
        while (controller.calculator.category_functions ().size == 0) {
            GLib.Timeout.add (100, () => {
                load_list.callback ();

                return false;
            });
            yield;
        }

        list_store.append (out iter);
        list_store.set (iter, 0, "NaSC", 1, "NaSC", 2, "NaSC", 3, "NaSC", 4, "NaSC", 5, "NaSC");

        foreach (var fe in get_nasc_functions ()) {
            list_store.append (out iter);
            list_store.set (iter, 0, fe.name, 1, fe.title, 2, fe.category, 3, fe.desc, 4, fe.args, 5, fe.args_list);
        }

        foreach (var entry in controller.calculator.category_functions ().ascending_entries) {
            if (entry.key == "NaSC") {
                continue;
            }

            list_store.append (out iter);
            list_store.set (iter, 0, entry.key, 1, entry.key, 2, entry.key, 3, entry.key, 4, entry.key, 5, entry.key);

            foreach (var fe in entry.value) {
                list_store.append (out iter);
                list_store.set (iter, 0, fe.name, 1, fe.title, 2, fe.category, 3, fe.desc, 4, fe.args, 5, fe.args_list);
            }
        }

        list_store.append (out iter);
        list_store.set (iter, 0, "Variables", 1, "Variables", 2, "Variables", 3, "Variables", 4, "Variables", 5, "Variables");

        foreach (var ve in controller.calculator.variables) {
            list_store.append (out iter);
            list_store.set (iter, 0, ve.name, 1, ve.title, 2, "Variables", 3, ve.desc, 4, "", 5, "");
        }

        list.set_model (list_store);

        /* connect signal */
        list.cursor_changed.connect (on_selection);
    }

    private async void reload_list () {
        list.cursor_changed.disconnect (on_selection);
        list_store.clear ();
        yield load_list ();
    }

    private Gee.ArrayList<NascFunction> get_nasc_functions () {
        var nasc = new Gee.ArrayList<NascFunction> ();
        nasc.add (new NascFunction.nasc ("", "Copy & Paste",
                                         "To support the referenced results there are 2 kind of copy in NaSC.\nThe normal copy via context menu or <i>Ctrl + c</i> will replace the referenced results with their real values.\nCopy via <i>Ctrl + Shift + C</i> will replace the referenced results with lineX references.\n\nPaste will connect lineX references with the corresponding results."));
        nasc.add (new NascFunction.nasc ("", "Referencing answers",
                                         "You can plug answers in to future equations and if that answer changes, so does the equations its used in.\n\nYou either can just click on a previous answer in the result pane, use the keyword <i>ans</i> for the last answer or the keyword <i>lineX</i> where X is the number of the line which you want to use."));
        nasc.add (new NascFunction.nasc ("", "Shortcuts",
                                         "<i>Ctrl + H</i> = Help\n<i>Ctrl + L</i> = Last Answer\n<i>Ctrl + N</i> = New Sheet\n<i>Ctrl + P</i> = π\n<i>Ctrl + R</i> = √\n\n<i>Ctrl + 0</i> = °\n<i>Ctrl + 2</i> = ²\n<i>Ctrl + 3</i> = ³\n<i>Ctrl + 4</i> = ⁴"));
        nasc.add (new NascFunction.nasc ("atom", "Periodic Table",
                                         "Show a Periodic Table. You can browse through the elements and insert properties into your calculation. Just click on the properties like for example the boiling point."));
         nasc.add (new NascFunction.nasc ("", "Scrubbing",
                                         "If you hover over a number you can manipulate this number while pressing the left mouse button and move the mouse to the left or to the right."));
        nasc.add (new NascFunction.nasc ("tutorial", "Tutorial",
                                         "Show the NaSC Tutorial again."));
        nasc.add (new NascFunction.nasc ("", "Unit Conversion",
                                         "You can convert various Units. The keyword is <i>to</i>.\n\nFor example:\n100€ to $\n23cm to in"));
        nasc.add (new NascFunction.nasc ("amath", "Advanced Math", ""));

        return nasc;
    }
}