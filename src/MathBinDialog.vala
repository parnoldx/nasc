/*
 * Copyright (c) 2020 Peter Arnold
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

    public class MathBinDialog : Gtk.Dialog {
        private Controller controller;

        public MathBinDialog (Gtk.Window? parent, Controller controller) {
            this.controller = controller;

            if (parent != null) {
                this.set_transient_for (parent);
            }

            var webkit = new WebKit.WebView ();
            var webkit_settings = new WebKit.Settings ();
            webkit_settings.default_font_family = Gtk.Settings.get_default ().gtk_font_name;
            webkit_settings.enable_back_forward_navigation_gestures = true;
            webkit_settings.enable_java = true;
            webkit_settings.enable_javascript = true;
            webkit_settings.enable_mediasource = true;
            webkit_settings.enable_plugins = false;
            webkit_settings.enable_smooth_scrolling = true;

            webkit.settings = webkit_settings;
            Gtk.Box content2 = get_content_area () as Gtk.Box;
            content2.add (webkit);
            webkit.set_size_request (800,600);

            show_all ();

            string paste_code = this.controller.get_export_text ();
            webkit.load_uri ("http://mathb.in");

            uint text_change_timeout = 0;
            webkit.load_changed.connect ((source, e)=> {
                if (text_change_timeout != 0) {
                    GLib.Source.remove (text_change_timeout);
                    text_change_timeout = 0;
                }
                text_change_timeout = Timeout.add (300, () => {
                    text_change_timeout = 0;

                    webkit.run_javascript   ("document.getElementById('code').value='"+paste_code+"'");

                    webkit.run_javascript   ("document.getElementById('title').value='"+controller.actual_sheet.name+"'");
                    return Source.REMOVE;
                });

            });
        }
    }
}
