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

namespace Nasc {
    public class NascApp : Granite.Application {
        private MainWindow window = null;
        public string[] args;

        construct {
            program_name = "NaSC";
            exec_name = "nasc";

            build_data_dir = Constants.DATADIR;
            build_pkg_data_dir = Constants.PKGDATADIR;
            build_release_name = Constants.RELEASE_NAME;
            build_version = Constants.VERSION;
            build_version_info = Constants.VERSION_INFO;

            app_years = "2015";
            app_icon = "nasc";
            app_launcher = "nasc.desktop";
            application_id = "net.launchpad.nasc";

            /* main_url = "https://code.launchpad.net/nasc"; */
            bug_url = "https://bugs.launchpad.net/nasc";
            help_url = "https://answers.launchpad.net/nasc";
            /* translate_url = "https://translations.launchpad.net/nasc"; */

            /* about_authors = { "NaSC Authors" }; */
            about_artists = { "Harvey Cabaguio <harvey@elementaryos.org>" };
            about_comments = "Do maths like a normal person";
            about_translators = null;
            about_license_type = Gtk.License.GPL_3_0;
        }

        public NascApp () {
            Granite.Services.Logger.initialize ("NaSC");
            Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.ERROR;
        }

        public override void activate () {
            if (get_windows () == null) {
                window = new MainWindow (this);
            } else {
                window.present ();
            }
        }

        public static void main (string[] args) {
            var app = new Nasc.NascApp ();
            app.args = args;
            app.run (args);
        }
    }
}