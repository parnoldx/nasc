/*
 * Copyright (c) 2021 Peter Arnold
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

public class NascSettings : Object {
    private static NascSettings? instance = null;

    /* constants */
    public const string variable_names = "nasc_line_";
    public const string sheet_split_char = "|§§|";
    public const string name_split_char = "-§-";
    public const string sheet_dir = "nasc";
   
   
    public bool dark_mode { get; private set; }
    public bool show_tutorial { get; set; }
    public bool advanced_mode { get; set; }
    public int window_width { get; set; }
    public int window_height { get; set; }
    public int pane_position { get; set; }
    public int opening_x { get; set; }
    public int opening_y { get; set; }

    public int open_sheet { get; set; }

    private NascSettings () {
        var settings = new GLib.Settings ("com.github.parnold_x.nasc");
        settings.bind ("show-tutorial", this, "show_tutorial", SettingsBindFlags.DEFAULT);
        settings.bind ("advanced-mode", this, "advanced_mode", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", this, "window_width", SettingsBindFlags.DEFAULT);
        settings.bind ("window-height", this, "window_height", SettingsBindFlags.DEFAULT);
        settings.bind ("pane-position", this, "pane_position", SettingsBindFlags.DEFAULT);
        settings.bind ("opening-x", this, "opening_x", SettingsBindFlags.DEFAULT);
        settings.bind ("opening-y", this, "opening_y", SettingsBindFlags.DEFAULT);
        settings.bind ("open-sheet", this, "open_sheet", SettingsBindFlags.DEFAULT);
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        // Then, we check if the user's preference is for the dark style and set it if it is
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        dark_mode = gtk_settings.gtk_application_prefer_dark_theme;

        // Finally, we listen to changes in Granite.Settings and update our app if the user changes their preference
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            dark_mode = gtk_settings.gtk_application_prefer_dark_theme;
        });
    }

    public static NascSettings get_instance () {
        if (instance == null) {
            instance = new NascSettings ();
        }

        return instance;
    }
}
