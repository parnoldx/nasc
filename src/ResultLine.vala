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

public class ResultLine : GLib.Object {
    public int line { get; set; }
    public string variable_name { get; set; }
    public string value { get; private set; }
    public string full_value { get; private set; }
    private Cairo.Context context;
    private int width;

    public signal void changed ();
    public signal void destroy ();

    public ResultLine (int line, string name, string value, int width) {
        this.line = line;
        this.variable_name = name;
        this.value = value;
        this.width = width;
        Cairo.ImageSurface source = new Cairo.ImageSurface (Cairo.Format.A8, 32, 32);
        context = new Cairo.Context (source);
        context.set_font_size (16);
    }

    /*
     * set the value of this line, emits a change signal,
     * if the line value has changed true will be returned
     */
    public bool set_value_with_notification (string value) {
        if (value == full_value) {
            return false;
        }

        this.full_value = value;
        set_val (value);
        changed ();

        return true;
    }

    public void set_val (string value) {
        Cairo.TextExtents extents;
        context.text_extents (value, out extents);

        if ((int)extents.width > width) {
            var tmp = value;

            while ((int)extents.width > 2 * width) {
                tmp = tmp.substring (0, tmp.length / 2);
                context.text_extents (tmp, out extents);
            }

            while ((int)extents.width > width) {
                tmp = tmp.substring (0, tmp.length - 1);
                context.text_extents (tmp, out extents);
            }

            tmp += "…";
            this.value = tmp;
        } else {
            this.value = value;
        }
    }

    public void refresh_width (int width) {
        this.width = width;

        if (full_value != null) {
            set_val (full_value);
        }
    }
}