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

public class InputView : Gtk.Box {
    public Gtk.SourceBuffer buffer;
    public Gtk.SourceView source_view;
    private Gtk.SourceSearchContext search;
    private Gee.ArrayList<ResultBoxWidget> result_widgets;
    public Gee.ArrayList<string> operators = new Gee.ArrayList<string> .wrap ({ "+", "-", "*", "/", "=" });
    private bool add_space = false;
    public bool skip_change = false;
    private Regex digit_regex;
    private Regex non_digit_regex;
    private string line_regex = "(?=[A-Za-z])line(\\d)+";
    public bool scroll_needed;
    private int total_lines = 0;
    private bool backspace_button = false;
    /* variable that holds actual cursor line */
    private int actual_line = 0;

    public signal void line_added (int starting, int count);
    public signal void line_removed (int starting, int count);
    public signal void changed_line (int line, int total_lines, string text);
    public signal void insert_result (int line);
    public signal void open ();
    public signal void new_trigger ();
    public signal void escape ();
    public signal void help ();
    public signal void quit ();
    public signal void cursor_line_change (int line);
    public signal void copy_result_to_clipboard (int line);
    public signal Gee.List<NascFunction> get_functions();

    public InputView () {
        try {
            digit_regex = new Regex ("\\d+", RegexCompileFlags.OPTIMIZE);
            non_digit_regex = new Regex ("[A-Za-z]", RegexCompileFlags.OPTIMIZE);
        } catch (GLib.RegexError ex) {
        }

        source_view = new Gtk.SourceView ();
        buffer = new Gtk.SourceBuffer (null);
        search = new Gtk.SourceSearchContext (buffer, new Gtk.SourceSearchSettings ());
        search.settings.set_regex_enabled (true);
        search.settings.set_case_sensitive (false);
        search.settings.set_search_text (line_regex);
        search.set_highlight (true);
        result_widgets = new Gee.ArrayList<ResultBoxWidget> ();
        source_view.set_buffer (buffer);
        source_view.set_show_line_numbers (true);
        source_view.set_left_margin (Nasc.left_margin - 5);
        source_view.set_pixels_below_lines (Nasc.vertical_padding);
        /* use 12pt font because the superscripts are displayed wrong if font is smaller! */
        var font_desc = source_view.get_style_context ().get_font (Gtk.StateFlags.NORMAL);
        font_desc.set_size (12 * Pango.SCALE);
        source_view.override_font (font_desc);
        /* if a operator is inserted, insert a blank before if none is set and insert one after it */
        source_view.buffer.insert_text.connect ((ref it, s, i) => {
            process_insert_text (ref it, s, i);
        });
        /* after change calculate actual line and all following and handling line insert and delete */
        source_view.buffer.changed.connect (() => {
            if (add_space || skip_change) {
                return;
            }

            Gtk.TextIter iter;
            source_view.buffer.get_iter_at_offset (out iter, source_view.buffer.cursor_position);
            int actual_line = iter.get_line ();
            int lines = source_view.buffer.text.split ("\n").length;

            /* line_count has changed -> react */
            if (lines != total_lines) {
                if (lines > total_lines) {
                    line_added (actual_line, lines - total_lines);
                } else {
                    if (backspace_button) {
                        line_removed (actual_line, total_lines - lines);
                    } else {
                        line_removed (actual_line - 1, total_lines - lines);
                    }
                }
            }

            total_lines = lines;
	    if (actual_line > 0) {
		actual_line--;
	    }
            changed_line (actual_line, lines, get_text_line_to_end (actual_line));
            scroll_needed = actual_line == lines - 1;
            backspace_button = false;
        });
        source_view.key_press_event.connect ((e) => {
            if (e.keyval == Gdk.Key.Escape) {
                skip_change = true;
                escape ();
                skip_change = false;

                return true;
            } else if (e.keyval == Gdk.Key.BackSpace) {
                backspace_button = true;

                return false;
            } else if (e.keyval == Gdk.Key.Return) {
                Gtk.TextIter iter;
                source_view.buffer.get_iter_at_offset (out iter, source_view.buffer.cursor_position);
                int offset = iter.get_offset ();

                source_view.buffer.insert_at_cursor (" ", -1);

                source_view.buffer.insert_at_cursor ("\n", -1);
                GLib.Timeout.add (2, () => {
                    Gtk.TextIter iter3, iter4;
                    iter3 = Gtk.TextIter ();
                    iter4 = Gtk.TextIter ();
                    source_view.buffer.get_iter_at_offset (out iter3, offset);
                    source_view.buffer.get_iter_at_offset (out iter4, offset+1);
                    source_view.buffer.delete (ref iter3, ref iter4);

                    return false;
                });

                return true;
            }

            if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                switch (e.keyval) {
                    case Gdk.Key.l:
                        var line = get_cursor_line ();

                        if (line == 0) {
                            return true;
                        }

                        insert_result (line - 1);

                        return true;

                    case Gdk.Key.o:
                        skip_change = true;
                        open ();
                        skip_change = false;

                        return true;

                    case Gdk.Key.n:
                        skip_change = true;
                        new_trigger ();
                        skip_change = false;

                        return true;

                    case Gdk.Key.r:
                        source_view.buffer.insert_at_cursor ("√", -1);

                        return true;

                    case Gdk.Key.p:
                        source_view.buffer.insert_at_cursor ("π", -1);

                        return true;

                    case Gdk.Key.h:
                        help ();

                        return true;

                    case Gdk.Key.q:
                        quit ();

                        return true;

                    case Gdk.Key.C:
                        var text = get_replaced_marked_content ();

                        if (text == null) {
                            //nothing selected so copy result
                            Gtk.TextIter iter;
                            source_view.buffer.get_iter_at_offset (out iter, source_view.buffer.cursor_position);
                            int actual_line = iter.get_line ();
                            copy_result_to_clipboard (actual_line);
                            return true;
                        }

                        Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD).set_text (text, -1);

                        return true;

                    case Gdk.Key.@0:
                        source_view.buffer.insert_at_cursor ("°", -1);

                        return true;

                    case Gdk.Key.@2:
                        source_view.buffer.insert_at_cursor ("²", -1);

                        return true;

                    case Gdk.Key.@3:
                        source_view.buffer.insert_at_cursor ("³", -1);

                        return true;

                    case Gdk.Key.@4:
                        source_view.buffer.insert_at_cursor ("⁴", -1);

                        return true;

                    default:
                        break;
                }
            }

            return false;
        });
        /* emit signal on cursor line change */
        source_view.buffer.notify["cursor-position"].connect ((s, p) => {
            Gtk.TextIter iter = Gtk.TextIter ();
            source_view.buffer.get_iter_at_offset (out iter, source_view.buffer.cursor_position);
            var line = iter.get_line ();

            if (actual_line != line) {
                cursor_line_change (line);
                actual_line = line;
            }
        });
        /* custom copy hook to convert resultwigets */
        source_view.copy_clipboard.connect (() => {
            GLib.Timeout.add (10, () => {
                var text = get_replaced_marked_real_content ();

                if (text == null) {
                    return false;
                }

                Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD).set_text (text, -1);

                return false;
            });
        });
        source_view.buffer.paste_done.connect ((c) => {
            changed_line (0, -1, get_text_line_to_end (0));
            /* TODO this should happen after the calculation is finished, so time is not good */
            GLib.Timeout.add (80, () => {
                process_new_content ();

                return false;
            });
        });
        /* enable scrubbing mode support */
        scrubbing_mode ();
        var alignment = new Gtk.Alignment (0, 0, 1, 1);
        alignment.top_padding = Nasc.top_padding;
        alignment.add (source_view);
        source_view.realize.connect (() => {
            var color = Gdk.RGBA ();
            source_view.get_style_context ().lookup_color ("theme_base_color", out color);
            this.override_background_color (Gtk.StateFlags.NORMAL, color);
        });
        this.pack_start (alignment);
        /* setup syntax highlighting */
        string[] dirs = { Constants.STYLEDIR};
        var lang_manager = Gtk.SourceLanguageManager.get_default ();
        lang_manager.set_search_path (dirs);
        this.buffer.set_language (lang_manager.get_language ("nasc"));
        var style_scheme_manager = new Gtk.SourceStyleSchemeManager ();
        style_scheme_manager.set_search_path (dirs);
        if (NascSettings.get_instance ().dark_mode) {
            this.buffer.style_scheme = style_scheme_manager.get_scheme ("nasc_dark");
        } else {
            this.buffer.style_scheme = style_scheme_manager.get_scheme ("nasc");
        }
    }

    private void process_insert_text (ref Gtk.TextIter it, string s, int i) {
        if (skip_change) {
            return;
        }

        if (add_space) {
            add_space = false;

            if (s != " " && s != "/") {
                skip_change = true;
                source_view.buffer.insert (ref it, " ", -1);
                skip_change = false;
            }

            return;
        }

        Gtk.TextIter iter, iter2;
        iter = Gtk.TextIter ();
        iter2 = Gtk.TextIter ();

        if (s == " " || operators.contains (s)) {
            /* check if "ans" for last answer or lineX for line X is typed */
            iter.assign (it);
            iter2.assign (it);

            if (check_pre_it ("ans", iter, iter2)) {
                int line = it.get_line ();

                if (line == 0) {
                    return;
                }

                skip_change = true;
                iter.assign (it);
                iter2.assign (it);
                int offset = iter.get_offset () + 1;
                /* to prevent errors, buffer delete makes the iter invalid which leads to errors */
                GLib.Timeout.add (1, () => {
                    Gtk.TextIter iter3, iter4;
                    iter3 = Gtk.TextIter ();
                    iter4 = Gtk.TextIter ();
                    source_view.buffer.get_iter_at_offset (out iter3, offset);
                    source_view.buffer.get_iter_at_offset (out iter4, offset);
                    iter3.backward_cursor_positions (4);
                    source_view.buffer.delete (ref iter3, ref iter4);
                    source_view.buffer.place_cursor (iter4);
                    offset = iter4.get_offset ();
                    insert_result (line - 1);

                    if (operators.contains (s)) {
                        source_view.buffer.get_iter_at_offset (out iter4, offset + 2);
                        source_view.buffer.insert (ref iter4, " "+s, -1);
                        source_view.buffer.get_iter_at_offset (out iter4, offset + 4);
                        add_space = true;
                    } else {
                        source_view.buffer.get_iter_at_offset (out iter4, offset + 2);
                        source_view.buffer.insert (ref iter4, " ", -1);
                        source_view.buffer.get_iter_at_offset (out iter4, offset + 2);
                    }

                    source_view.buffer.place_cursor (iter4);
                    skip_change = false;
                    changed_line (line, -1, get_text_line_to_end (line));

                    return false;
                });

                return;
            }

            iter.assign (it);
            iter2.assign (it);
            int res = check_pre_it_before_digits ("line", iter, iter2);
            var line = it.get_line ();

            if (res > 0 && res <= line) {
                skip_change = true;
                iter.assign (it);
                iter2.assign (it);
                int offset = iter.get_offset () + 1;
                /* to prevent errors, buffer delete makes the iter invalid which leads to errors */
                GLib.Timeout.add (1, () => {
                    Gtk.TextIter iter3, iter4;
                    iter3 = Gtk.TextIter ();
                    iter4 = Gtk.TextIter ();
                    source_view.buffer.get_iter_at_offset (out iter3, offset);
                    source_view.buffer.get_iter_at_offset (out iter4, offset);
                    iter3.backward_cursor_positions (5 + res.to_string ().length);
                    source_view.buffer.delete (ref iter3, ref iter4);
                    source_view.buffer.place_cursor (iter4);
                    offset = iter4.get_offset ();
                    insert_result (res - 1);

                    if (operators.contains (s)) {
                        source_view.buffer.get_iter_at_offset (out iter4, offset + 2);
                        source_view.buffer.insert (ref iter4, " "+s, -1);
                        source_view.buffer.get_iter_at_offset (out iter4, offset + 4);
                        add_space = true;
                    } else {
                        source_view.buffer.get_iter_at_offset (out iter4, offset + 2);
                        source_view.buffer.insert (ref iter4, " ", -1);
                        source_view.buffer.get_iter_at_offset (out iter4, offset + 2);
                    }

                    source_view.buffer.place_cursor (iter4);
                    skip_change = false;
                    changed_line (line, -1, get_text_line_to_end (line));

                    return false;
                });

                return;
            }
        }


        if (operators.contains (s)) {
            source_view.buffer.get_iter_at_line_index (out iter2, it.get_line (), 0);

            if (source_view.buffer.get_slice (iter2, it, true).contains ("http:")) {
                return;
            }

            iter.assign (it);
            iter.backward_cursor_position ();
            var pre_last_char = source_view.buffer.get_slice (iter, it, true);
            if (!(pre_last_char == " " || pre_last_char == "/")) {
                skip_change = true;
                source_view.buffer.insert (ref it, " ", -1);
                skip_change = false;
            }

            add_space = true;
        }
    }

    public void process_new_content () {
        /* scan all lines for lineX and replace them */
        skip_change = true;
        int cursor_pos;
        Gtk.TextIter start_iter, end_iter, cursor;
        bool has_wrapped_around;
        source_view.buffer.get_iter_at_offset (out cursor, source_view.buffer.cursor_position);
        cursor_pos = cursor.get_offset ();
        source_view.buffer.get_iter_at_offset (out start_iter, 0);
        end_iter = start_iter;
        int[] index_array = {};
        int[] line_array = {};
        int delta = 0;

        while (search.forward2 (start_iter, out start_iter, out end_iter, out has_wrapped_around)) {
            MatchInfo info;
            var text = source_view.buffer.get_text (start_iter, end_iter, false);
            digit_regex.match (text, 0, out info);
            int line = int.parse (info.fetch (0));

            if (line == 0) {
                continue;
            }

            source_view.buffer.delete (ref start_iter, ref end_iter);
            index_array += start_iter.get_offset () - delta;
            line_array += line - 1;
            delta = start_iter.get_offset ();
        }

        int index = 0;

        for (int i = 0; i < index_array.length; i++) {
            source_view.buffer.get_iter_at_offset (out cursor, index);
            cursor.forward_chars (index_array[i]);
            source_view.buffer.place_cursor (cursor);
            insert_result (line_array[i]);
            index = source_view.buffer.cursor_position;
        }

        skip_change = false;
        source_view.buffer.get_iter_at_offset (out cursor, cursor_pos);
        source_view.buffer.place_cursor (cursor);
        changed_line (0, -1, get_text_line_to_end (0));
    }

    private int check_pre_it_before_digits (string s, Gtk.TextIter iter, Gtk.TextIter iter2) {
        string digit = "";
        iter.backward_cursor_position ();

        if (iter.get_line_offset () == 0) {
            return -1;
        }

        string iter_char = source_view.buffer.get_slice (iter, iter2, true);

        while (digit_regex.match (iter_char)) {
            digit += iter_char;
            iter.backward_cursor_position ();

            if (iter.get_line_offset () == 0) {
                return -1;
            }

            iter2.backward_cursor_position ();
            iter_char = source_view.buffer.get_slice (iter, iter2, true);
        }

        if (iter_char != s.substring (s.length - 1, 1)) {
            return -1;
        }

        iter2.backward_cursor_position ();

        if (check_pre_it (s.substring (0, s.length - 1), iter, iter2)) {
            return int.parse (digit.reverse ());
        }

        return -1;
    }

    private bool check_pre_it (string s, Gtk.TextIter iter, Gtk.TextIter iter2) {
        iter.backward_cursor_position ();

        if (iter.get_line_offset () == 0) {
            return false;
        }
        for (int i = s.length - 1; i >= 0; i--) {
            string s_char = s.substring (i, 1);
            var iter_char = source_view.buffer.get_slice (iter, iter2, true);

            if (s_char != iter_char) {
                return false;
            }

            iter.backward_cursor_position ();
            iter2.backward_cursor_position ();
        }
        /* if pre char is a letter character return false */
        var iter_char = source_view.buffer.get_slice (iter, iter2, true);

        if (non_digit_regex.match (iter_char)) {
            return false;
        }

        return true;
    }

    public override bool draw (Cairo.Context context) {
        var ret = base.draw (context);

        /*
         * workaround for the shit anchor widget positioning
         * reserving space with the widget as anchor and drawing the content within the box context
         */
        foreach (var widget in result_widgets) {
            int dest_x, dest_y;
            widget.translate_coordinates (this, 0, 0, out dest_x, out dest_y);
            widget.draw_content (context, dest_x, dest_y);
        }

        return ret;
    }

    public void insert_text (string text) {
        source_view.buffer.insert_at_cursor (text, text.length);
    }

    public void delete_characters (int count) {
        Gtk.TextIter iter, iter2;
        iter = Gtk.TextIter ();
        iter2 = Gtk.TextIter ();
        int offset = source_view.buffer.cursor_position;
        source_view.buffer.get_iter_at_offset (out iter, offset);
        source_view.buffer.get_iter_at_offset (out iter2, offset);
        iter.backward_cursor_positions (count);
        source_view.buffer.delete (ref iter, ref iter2);
    }

    public void insert_variable (ResultLine res) {
        if (add_space) {
            skip_change = true;
            source_view.buffer.insert_at_cursor (" ", -1);
            skip_change = false;
        }

        Gtk.TextIter iter;
        source_view.buffer.get_iter_at_offset (out iter, source_view.buffer.cursor_position);
        int actual_line = iter.get_line ();

        if (res.line >= actual_line) {
            return;
        }

        var anchor = source_view.buffer.create_child_anchor (iter);
        ResultBoxWidget widget = new ResultBoxWidget (actual_line, res);
        source_view.add_child_at_anchor (widget, anchor);

        if (!skip_change) {
            source_view.buffer.get_iter_at_offset (out iter, source_view.buffer.cursor_position);
            source_view.buffer.insert (ref iter, " ", 1);
        }

        result_widgets.add (widget);
        widget.destroy.connect (() => {
            result_widgets.remove (widget);
        });
        widget.result.changed.connect (() => {
            queue_draw ();
        });
    }

    public int get_cursor_line () {
        Gtk.TextIter iter;
        source_view.buffer.get_iter_at_offset (out iter, source_view.buffer.cursor_position);

        return iter.get_line ();
    }

    public string get_text_line_to_end (int line) {
        Gtk.TextIter start, end;
        this.buffer.get_iter_at_line (out start, line);
        this.buffer.get_end_iter (out end);

        if (start.get_offset () == end.get_offset ()) {
            return "";
        }

        var text = this.buffer.get_slice (start, end, false);
        text = replace_widget_markers (line, text, true, false);

        return text;
    }

    /* get content with lineX replacements */
    public string get_replaced_content (bool real_values = false) {
        Gtk.TextIter start, end;
        this.buffer.get_start_iter (out start);
        this.buffer.get_end_iter (out end);

        if (start.get_offset () == end.get_offset ()) {
            return "";
        }

        var text = this.buffer.get_slice (start, end, false);
        text = replace_widget_markers (0, text, false, real_values);

        return text;
    }

    /* get marked content with lineX replacements */
    public string? get_replaced_marked_content () {
        Gtk.TextIter start, end;

        if (!this.buffer.get_selection_bounds (out start, out end)) {
            return null;
        }

        var text = this.buffer.get_slice (start, end, false);
        text = replace_widget_markers (0, text, false, false);

        return text;
    }

    /* get marked content with real value replacements */
    public string? get_replaced_marked_real_content () {
        Gtk.TextIter start, end;

        if (!this.buffer.get_selection_bounds (out start, out end)) {
            return null;
        }

        var text = this.buffer.get_slice (start, end, false);
        text = replace_widget_markers (0, text, false, true);

        return text;
    }

    /*
     * replace widgets with the variable_names or real values
     * bit tricky because the indexes of the buffer text
     * and the indexes of the iter offset are different
     */
    private string replace_widget_markers (int line_number, string text, bool for_calculator, bool real_values) {
        var return_text = text;

        if (return_text == "") {
            return return_text;
        }

        Gtk.TextIter iter;
        int[] replacement_indexes = {};
        unichar c;
        int j = 0;

        for (int i = 0; return_text.get_next_char (ref i, out c);) {
            if ("￼" == c.to_string ()) {
                replacement_indexes += j;
            }

            j++;
        }

        int delta = 0;

        foreach (int i in replacement_indexes) {
            string replacement = "";
            this.buffer.get_iter_at_line_offset (out iter, line_number, 0);
            this.buffer.get_iter_at_offset (out iter, iter.get_offset () + i);
            var anchor = iter.get_child_anchor ();

            if (anchor != null) {
                foreach (var w in anchor.get_widgets ()) {
                    ResultBoxWidget ws = w as ResultBoxWidget;

                    if (ws != null) {
                        if (real_values) {
                            replacement = ws.result.full_value;
                        } else if (for_calculator) {
                            replacement = ws.get_variable_name ();
                        } else {
                            replacement = "line%d".printf (ws.result.line + 1);
                        }
                    }
                }
            }

            return_text = return_text.splice (return_text.index_of_nth_char (i + delta),
                                              return_text.index_of_nth_char (i + 1 + delta), replacement);
            delta += replacement.length - 1;
        }

        return return_text;
    }

    /* scrubbing mode */
    private Gdk.Cursor x_term = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.XTERM);
    private Gdk.Cursor d_arrow = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.SB_H_DOUBLE_ARROW);
    bool scrubb_hover = false;
    private int scrubb_press_x = -1;
    private int org_value;
    private int start_scrub;
    private int scrub_width;
    private Gtk.TextTag scrub_tag;
    private int last_cursor;

    /* call to enable scrubbing mode */
    private void scrubbing_mode () {
        source_view.motion_notify_event.connect ((e) => {
            Gtk.TextIter iter, iter2;
            iter = Gtk.TextIter ();
            iter2 = Gtk.TextIter ();

            if (scrubb_press_x > 0) {
                int delta = -scrubb_press_x + (int)e.x;
                var new_value = "%d".printf (org_value + delta);
                source_view.buffer.get_iter_at_offset (out iter, start_scrub);
                source_view.buffer.get_iter_at_offset (out iter2, start_scrub + scrub_width);
                scrub_width = new_value.length;
                skip_change = true;
                source_view.buffer.@delete (ref iter, ref iter2);
                skip_change = false;
                source_view.buffer.get_iter_at_offset (out iter, start_scrub);
                source_view.buffer.insert_with_tags (ref iter, new_value, new_value.length, scrub_tag, null);

                return Gdk.EVENT_STOP;
            }

            int x, y;
            source_view.window_to_buffer_coords (Gtk.TextWindowType.TEXT, (int)e.x, (int)e.y, out x, out y);
            source_view.get_iter_at_location (out iter, x, y);
            source_view.buffer.get_end_iter (out iter2);

            if (iter.get_offset () == iter2.get_offset ()) {
                if (scrubb_hover) {
                    source_view.get_window (Gtk.TextWindowType.TEXT).set_cursor (x_term);
                    scrubb_hover = false;
                }

                return false;
            }

            iter2.assign (iter);
            iter.backward_word_start ();
            forward_till_no_digit (ref iter2);
            var word = source_view.buffer.get_slice (iter, iter2, true);
            start_scrub = iter.get_offset ();
            iter.backward_char ();

            /* we leave out double for now */
            if (iter.get_char () == ',' || iter2.get_char () == ',' || iter.get_char () == '.' || iter2.get_char () == '.') {
                if (scrubb_hover) {
                    source_view.get_window (Gtk.TextWindowType.TEXT).set_cursor (x_term);
                    scrubb_hover = false;
                }

                return false;
            }

            int64 val;
            bool success = int64.try_parse (word, out val);

            if (success) {
                if (!scrubb_hover) {
                    org_value = (int)val;
                    scrub_width = "%d".printf (org_value).length;
                    iter.forward_char ();
                    source_view.get_window (Gtk.TextWindowType.TEXT).set_cursor (d_arrow);
                    scrubb_hover = true;
                }
            } else {
                if (scrubb_hover) {
                    source_view.get_window (Gtk.TextWindowType.TEXT).set_cursor (x_term);
                    scrubb_hover = false;
                }
            }

            return false;
        });
        source_view.button_press_event.connect ((e) => {
            if (scrubb_hover && e.type == Gdk.EventType.BUTTON_PRESS &&
                e.button != Gdk.EventType.@2BUTTON_PRESS) {
                scrubb_press_x = (int)e.x;
                last_cursor = source_view.buffer.cursor_position;
                source_view.cursor_visible = false;
                Gtk.TextIter iter = Gtk.TextIter ();
                source_view.buffer.get_iter_at_offset (out iter, start_scrub);
                source_view.buffer.place_cursor (iter);

                return Gdk.EVENT_STOP;
            } else {
                return Gdk.EVENT_PROPAGATE;
            }
        });
        source_view.button_release_event.connect ((e) => {
            if (scrubb_press_x > 0) {
                scrubb_press_x = -1;
                source_view.get_window (Gtk.TextWindowType.TEXT).set_cursor (x_term);
                scrubb_hover = false;
                Gtk.TextIter iter, iter2;
                iter = Gtk.TextIter ();
                iter2 = Gtk.TextIter ();
                source_view.buffer.get_iter_at_offset (out iter, start_scrub);
                source_view.buffer.get_iter_at_offset (out iter2, start_scrub + scrub_width);
                source_view.buffer.remove_tag_by_name ("scrubbing", iter, iter2);
                source_view.cursor_visible = true;
                source_view.buffer.get_iter_at_offset (out iter, last_cursor);
                source_view.buffer.place_cursor (iter);

                return Gdk.EVENT_STOP;
            } else {
                return Gdk.EVENT_PROPAGATE;
            }
        });
        scrub_tag = source_view.buffer.create_tag ("scrubbing");
        Gdk.RGBA rgb = Gdk.RGBA ();
        rgb.red = 0.854901961;
        rgb.green = 0.933333333;
        rgb.blue = 0.984313725;
        rgb.alpha = 0.8;
        scrub_tag.background_rgba = rgb;
        scrub_tag.background_set = true;
    }

    private void forward_till_no_digit (ref Gtk.TextIter it) {
        while (true) {
            it.forward_char ();

            if (it.get_char ().isdigit ()) {
                continue;
            }

            break;
        }
    }
}
