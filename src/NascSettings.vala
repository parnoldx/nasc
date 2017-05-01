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

public class NascSettings : Granite.Services.Settings {
    private static NascSettings? instance = null;

    /* constants */
    public const string variable_names = "nasc_line_";
    public const string sheet_split_char = "|§§|";
    public const string name_split_char = "-§-";
    public const string sheet_path = "/.local/share/nasc/";
    public const string template_path = "/usr/share/qalculate/nasc_template.sheets";

    public bool show_tutorial { get; set; }
    public bool advanced_mode { get; set; }
    public int window_width { get; set; }
    public int window_height { get; set; }
    public int pane_position { get; set; }
    public int opening_x { get; set; }
    public int opening_y { get; set; }

    public int open_sheet { get; set; }

    private NascSettings () {
        base ("net.launchpad.nasc");
    }

    public static NascSettings get_instance () {
        if (instance == null) {
            instance = new NascSettings ();
        }

        return instance;
    }
}