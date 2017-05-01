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

public class ResultView : Gtk.Box {
    private Gtk.TextView text_view;
    private Gdk.Cursor left_ptr = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.LEFT_PTR);
    private Gdk.Cursor hand = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.HAND2);
    private bool hovering_over_result = false;
    public Gee.ArrayList<ResultLine> result_list  { get; private set; }
    private const int START_WIDTH = 210;
    private int actual_width = START_WIDTH;
    private bool update_needed;
    private Gtk.TextTag bold_tag;
    private Gtk.Spinner spinner;
    private Gtk.Bin spinner_box;

    public signal void insert_variable (ResultLine rw);

    public ResultView () {
        result_list = new Gee.ArrayList<ResultLine> ();
        spinner = new Gtk.Spinner ();
        spinner.start ();
        spinner_box = new Gtk.Alignment (0.9f, 0, 0, 0);
        spinner_box.add (spinner);
        spinner_box.no_show_all = true;
        spinner_box.set_size_request (20, -1);
        spinner.set_size_request (20, 20);
        text_view = new Gtk.TextView ();
        text_view.set_size_request (START_WIDTH, -1);
        text_view.set_editable (false);
        text_view.set_cursor_visible (false);
        text_view.left_margin = Nasc.left_margin;
        text_view.set_pixels_below_lines (Nasc.vertical_padding);
        text_view.set_can_focus (false);
        bold_tag = text_view.buffer.create_tag ("bold");
        bold_tag.weight = Pango.Weight.BOLD;
        /* use 12pt font because the superscripts are displayed wrong if font is smaller! */
        var font_desc = text_view.get_style_context ().get_font (Gtk.StateFlags.NORMAL);
        font_desc.set_size (12 * Pango.SCALE);
        text_view.override_font (font_desc);
        /* background color very light grey */
        var color = Gdk.RGBA ();
        color.red = 230;
        color.green = 230;
        color.blue = 230;
        color.alpha = 0;
        text_view.override_background_color (Gtk.StateFlags.NORMAL, color);
        /* listen on result press */
        text_view.set_events (Gdk.EventMask.BUTTON_PRESS_MASK);
        text_view.button_press_event.connect ((evt) => {
            if (!hovering_over_result) {
                return false;
            }

            Gtk.TextIter start, end, iter;
            int x, y;

            text_view.buffer.get_selection_bounds (out start, out end);

            if (start.get_offset () != end.get_offset ()) {
                return false;
            }

            text_view.window_to_buffer_coords (Gtk.TextWindowType.TEXT, (int)evt.x, (int)evt.y, out x, out y);
            text_view.get_iter_at_location (out iter, x, y);
            int line_number = iter.get_line ();
            insert_variable (result_list.get (line_number));
            text_view.get_window (Gtk.TextWindowType.TEXT).set_cursor (left_ptr);

            return false;
        });
        /* listen on result hovering */
        text_view.set_events (Gdk.EventMask.POINTER_MOTION_MASK);
        text_view.motion_notify_event.connect ((evt) => {
            Gtk.TextIter iter;
            int x, y;
            text_view.window_to_buffer_coords (Gtk.TextWindowType.TEXT, (int)evt.x, (int)evt.y, out x, out y);
            text_view.get_iter_at_location (out iter, x, y);
            bool hovering = false;

            foreach (var tag in iter.get_tags ()) {
                hovering = true;
            }

            if (hovering != hovering_over_result) {
                hovering_over_result = hovering;

                if (hovering_over_result) {
                    text_view.get_window (Gtk.TextWindowType.TEXT).set_cursor (hand);
                } else {
                    text_view.get_window (Gtk.TextWindowType.TEXT).set_cursor (left_ptr);
                }
            }

            return false;
        });
        var alignment = new Gtk.Alignment (0, 0, 1, 1);
        alignment.top_padding = Nasc.top_padding;
        alignment.add (text_view);
        this.override_background_color (Gtk.StateFlags.NORMAL, color);
        this.pack_start (alignment);
        this.pack_start (spinner_box);
    }

    public void set_width (int width) {
        actual_width = width - 5;

        foreach (var rl in result_list) {
            rl.refresh_width (actual_width);
        }

        update (actual_line, true);
    }

    public override bool draw (Cairo.Context cr) {
        var res = base.draw (cr);
        /* change cursor to normal */
        text_view.get_window (Gtk.TextWindowType.TEXT).set_cursor (left_ptr);

        return res;
    }

    /* shows a spinner at the line */
    public void show_spinner (int line) {
        spinner_box.no_show_all = false;
        spinner.margin_top = Nasc.top_padding + (line * 27);
        spinner_box.show_all ();
        /*
         * for (int i = line; i < result_list.size; i++) {
         *     var res = result_list.get (i);
         *     res.set_val ("");
         * }
         * update (line, true);
         */
    }

    public void hide_spinner () {
        spinner_box.hide ();
        spinner_box.no_show_all = true;
    }

    public void set_line (int index, string result) {
        var line_res = result;

        if (index < result_list.size) {
            var res = result_list.get (index);
            var update = res.set_value_with_notification (line_res);

            if (update) {
                update_needed = true;
            }
        }
    }

    public void add_line (int line, int count) {
        /* add new line/lines */
        for (int i = 0; i < count; i++) {
            if (i + line > result_list.size) {
                string variable_name = NascSettings.variable_names + "%d".printf (result_list.size);
                result_list.add (new ResultLine (result_list.size, variable_name, "", actual_width));
            } else {
                string variable_name = NascSettings.variable_names + "%d".printf (i + line);
                result_list.insert (i + line, new ResultLine (i + line, variable_name, "", actual_width));
            }
        }

        /* update all lines greater than line */
        for (int i = result_list.size - 1; i >= line + count; i--) {
            var tmp = result_list.get (i);
            tmp.line = i;
            tmp.variable_name = NascSettings.variable_names + "%d".printf (i);
        }
    }

    public void remove_line (int line, int count) {
        if (line <= 0 && count == result_list.size) {
            result_list.clear ();

            return;
        }

        for (int i = line + count; i > line; i--) {
            if (result_list.size > i) {
                result_list.remove_at (i);
                update_needed = true;
            }
        }

        /* update all lines greater than line */
        for (int i = result_list.size - 1; i >= line; i--) {
            if (i == -1) {
                break;
            }

            var tmp = result_list.get (i);
            tmp.line = i;
            tmp.variable_name = NascSettings.variable_names + "%d".printf (i);
        }
    }

    public void clear () {
        result_list.clear ();
        text_view.buffer.text = "";
    }

    private int actual_line;
    public void update (int line, bool force = false) {
        this.actual_line = line;

        if (!update_needed && !force && result_list.size != 0) {
            return;
        }

        Gtk.TextIter iter;
        text_view.buffer.text = "";
        text_view.buffer.get_iter_at_offset (out iter, 0);

        /* setting results */
        for (int i = 0; i < result_list.size; i++) {
            var res = result_list.get (i);
            Gtk.TextTag tag = text_view.buffer.tag_table.lookup (NascSettings.variable_names + "%d".printf (i));

            if (tag == null) {
                tag = text_view.buffer.create_tag (NascSettings.variable_names + "%d".printf (i), null);
            }

            if (i == line) {
                text_view.buffer.insert_with_tags (ref iter, res.value, -1, tag, bold_tag, null);
            } else {
                text_view.buffer.insert_with_tags (ref iter, res.value, -1, tag, null);
            }

            if (i != (result_list.size - 1)) {
                text_view.buffer.get_end_iter (out iter);
                text_view.buffer.insert (ref iter, "\n", 1);
            }
        }

        update_needed = false;
    }
}