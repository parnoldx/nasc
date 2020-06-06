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

public class ResultBoxWidget : Gtk.DrawingArea {
    public int line_number { get; set; }
    public ResultLine result;

    public ResultBoxWidget (int line_number, ResultLine result) {
        this.line_number = line_number;
        this.result = result;
        this.set_size_request (15, 15);
        show ();
        this.result.changed.connect (() => {
            queue_draw ();
        });
        result.destroy.connect (() => {
            this.destroy ();
        });
    }

    public string get_variable_name () {
        return this.result.variable_name;
    }

    public override bool draw (Cairo.Context context) {
        context.set_font_size (16);
        Cairo.TextExtents extents;
        context.text_extents (this.result.value, out extents);
        int box_width = ((int)extents.width) + 2 * 8;
        this.set_size_request (box_width, 15);

        return true;
    }

    public bool draw_content (Cairo.Context context, int x, int y) {
        context.set_font_size (16);
        Cairo.TextExtents extents;
        context.text_extents (this.result.value, out extents);
        /* set and calculate sizes of the box */
        int dy = -2;
        int box_dx_text = 8;
        int box_mdy_text = 5;
        int box_height = 22;
        int box_width = ((int)extents.width) + 2 * box_dx_text;
        /* draw box */
        if (NascSettings.get_instance ().dark_mode) {
            context.set_source_rgba (0.854901961, 0.933333333, 0.984313725, 0.9);
        } else {
            context.set_source_rgba (0.854901961, 0.933333333, 0.984313725, 0.6);
        }
        context.set_line_width (1);
        roundedrec (context, x, y + dy, box_width, box_height, 4, true);
        roundedrec (context, x, y + dy, box_width, box_height, 4, false);
        context.move_to (x + box_dx_text - 1, y + dy + box_height - box_mdy_text);
        /* draw text */
        context.set_source_rgba (0.145098039, 0.42745098, 0.615686275, 1);
        context.show_text (this.result.value);
        context.stroke ();

        return true;
    }

    private void roundedrec (Cairo.Context cr, int x, int y, int width, int height, int radius = 5, bool fill = false) {
        int x0 = x + radius / 2;
        int y0 = y + radius / 2;
        int rect_width = width - radius;
        int rect_height = height - radius;

        cr.save ();

        int x1 = x0 + rect_width;
        int y1 = y0 + rect_height;

        if (rect_width / 2 < radius) {
            if (rect_height / 2 < radius) {
                cr.move_to (x0, (y0 + y1) / 2);
                cr.curve_to (x0, y0, x0, y0, (x0 + x1) / 2, y0);
                cr.curve_to (x1, y0, x1, y0, x1, (y0 + y1) / 2);
                cr.curve_to (x1, y1, x1, y1, (x1 + x0) / 2, y1);
                cr.curve_to (x0, y1, x0, y1, x0, (y0 + y1) / 2);
            } else {
                cr.move_to (x0, y0 + radius);
                cr.curve_to (x0, y0, x0, y0, (x0 + x1) / 2, y0);
                cr.curve_to (x1, y0, x1, y0, x1, y0 + radius);
                cr.line_to (x1, y1 - radius);
                cr.curve_to (x1, y1, x1, y1, (x1 + x0) / 2, y1);
                cr.curve_to (x0, y1, x0, y1, x0, y1 - radius);
            }
        } else {
            if (rect_height / 2 < radius) {
                cr.move_to (x0, (y0 + y1) / 2);
                cr.curve_to (x0, y0, x0, y0, x0 + radius, y0);
                cr.line_to (x1 - radius, y0);
                cr.curve_to (x1, y0, x1, y0, x1, (y0 + y1) / 2);
                cr.curve_to (x1, y1, x1, y1, x1 - radius, y1);
                cr.line_to (x0 + radius, y1);
                cr.curve_to (x0, y1, x0, y1, x0, (y0 + y1) / 2);
            } else {
                cr.move_to (x0, y0 + radius);
                cr.curve_to (x0, y0, x0, y0, x0 + radius, y0);
                cr.line_to (x1 - radius, y0);
                cr.curve_to (x1, y0, x1, y0, x1, y0 + radius);
                cr.line_to (x1, y1 - radius);
                cr.curve_to (x1, y1, x1, y1, x1 - radius, y1);
                cr.line_to (x0 + radius, y1);
                cr.curve_to (x0, y1, x0, y1, x0, y1 - radius);
            }
        }

        cr.close_path ();

        if (fill) {
            cr.fill ();
        }

        cr.restore ();
    }
}