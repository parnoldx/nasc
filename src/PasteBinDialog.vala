/*
 * Copyright (c) 2011-2012 Giulio Collura <random.cpp@gmail.com>
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

using Gtk;
using Soup;

public const string NAME = N_("Pastebin");
public const string DESCRIPTION = N_("Share files with pastebin service");

namespace Nasc {
    public class PasteBin : GLib.Object {
        public const int PASTE_ID_LEN = 9;

        public const string NEVER = "N";
        public const string TEN_MINUTES = "10M";
        public const string HOUR = "1H";
        public const string DAY = "1D";
        public const string MONTH = "1M";

        public const string PRIVATE = "1";
        public const string PUBLIC = "0";

        public static int submit (out string link, string paste_code, string paste_name,
                                  string paste_private, string paste_expire_date) {
            /* Code meaning:
             *  0 = it's all ok
             *  1 = generic error
             *  2 = text (paste_code) is empty
             *  3 = invalid file format
             *  ... maybe we should add and handle other errors...
             */

            /* check input values */
            if (paste_code.length == 0) {
                link = "";

                return 2;
            }

            string api_url = "https://pastebin.com/api/api_post.php";

            var session = new Session ();
            var message = new Message ("POST", api_url);

            string request = Form.encode (
                "api_option", "paste",
                "api_dev_key", "67480801fa55fc0977f7561cf650a339",
                "api_paste_code", paste_code,
                "api_paste_name", paste_name,
                "api_paste_private", paste_private,
                "api_paste_expire_date", paste_expire_date,
                "api_paste_format", "matlab");

            message.set_request ("application/x-www-form-urlencoded", MemoryUse.COPY, request.data);
            message.set_flags (MessageFlags.NO_REDIRECT);

            session.send_message (message);
            var output = (string)message.response_body.data;

            /* check return value */
            if (output[0 : 4] == "http") {
                /* we need only pastebin url len + id len */
                output = output[0 : 20 + PASTE_ID_LEN];
                debug (output);
                link = output;
            } else {
                /* paste error */
                link = "";

                switch (output) {
                    case "ERROR: Invalid POST request, or \"paste_code\" value empty":

                        return 2;

                    case "ERROR: Invalid file format":

                        return 3;

                    default:

                        return 1;
                }
            }

            return 0;
        }
    }

    public class PasteBinDialog : Gtk.Dialog {
        private Box content;
        private Box padding;

        private Entry name_entry;
        private ComboBoxText expiry_combo;
        private CheckButton private_check;

        private Button send_button;

        private Controller controller;

        public PasteBinDialog (Gtk.Window? parent, Controller controller) {
            this.controller = controller;

            if (parent != null) {
                this.set_transient_for (parent);
            }

            this.set_title (_("Share via PasteBin"));
            Gtk.Box content2 = get_content_area () as Gtk.Box;
            var label = new Gtk.Label ("");
            string lab = _("Share via PasteBin");
            label.set_markup (@"<b>$lab</b>");
            content2.add (label);
            create_dialog ();

            send_button.clicked.connect (send_button_clicked);
        }

        private void create_dialog () {
            content = new Box (Gtk.Orientation.VERTICAL, 10);
            padding = new Box (Gtk.Orientation.HORIZONTAL, 10);

            name_entry = new Entry ();
            name_entry.text = "Test";
            var name_entry_l = new Label (_("Name:"));
            var name_entry_box = new Box (Gtk.Orientation.HORIZONTAL, 58);
            name_entry_box.pack_start (name_entry_l, false, true, 0);
            name_entry_box.pack_start (name_entry, true, true, 0);

            expiry_combo = new ComboBoxText ();
            populate_expiry_combo ();
            expiry_combo.set_active (0);
            var expiry_combo_l = new Label (_("Expiry time:"));
            var expiry_combo_box = new Box (Gtk.Orientation.HORIZONTAL, 28);
            expiry_combo_box.pack_start (expiry_combo_l, false, true, 0);
            expiry_combo_box.pack_start (expiry_combo, true, true, 0);

            private_check = new CheckButton.with_label (_("Keep this paste private"));
            send_button = new Button.with_label (_("Upload"));

            var bottom_buttons = new ButtonBox (Gtk.Orientation.HORIZONTAL);
            bottom_buttons.set_layout (ButtonBoxStyle.CENTER);
            bottom_buttons.set_spacing (10);
            bottom_buttons.pack_end (send_button);

            content.pack_start (wrap_alignment (name_entry_box, 12, 0, 0, 0), true, true, 0);
            content.pack_start (expiry_combo_box, true, true, 0);
            content.pack_start (private_check, true, true, 0);
            content.pack_end (bottom_buttons, true, true, 12);

            padding.pack_start (content, false, true, 12);

            Gtk.Box content2 = get_content_area () as Gtk.Box;
            content2.add (padding);

            show_all ();

            send_button.grab_focus ();
        }

        private static Alignment wrap_alignment (Widget widget, int top, int right,
                                                 int bottom, int left) {
            var alignment = new Alignment (0.0f, 0.0f, 1.0f, 1.0f);
            alignment.top_padding = top;
            alignment.right_padding = right;
            alignment.bottom_padding = bottom;
            alignment.left_padding = left;

            alignment.add (widget);

            return alignment;
        }

        private void send_button_clicked () {
            content.hide ();
            /* Probably your connection is too fast to not see this */
            var spinner = new Spinner ();
            padding.pack_start (spinner, true, true, 10);
            spinner.show ();
            spinner.start ();

            string link;
            var submit_result = submit_paste (out link);

            /* Show the new view */
            spinner.hide ();

            var box = new Box (Gtk.Orientation.VERTICAL, 10);

            if (submit_result == 0) {
                /* paste successfully */
                var link_button = new LinkButton (link);
                box.pack_start (link_button, false, true, 25);
            } else {
                /* paste error */
                var error_desc = new StringBuilder ();

                switch (submit_result) {
                    case 2 :
                        error_desc.append ("The text is void!");
                        break;

                    case 3:
                        error_desc.append ("The text format doesn't exist");
                        break;

                    default:
                        error_desc.append ("An error occured");
                        break;
                }

                error_desc.append ("\n" + "The text was sent");
                var err_label = new Label (error_desc.str);
                box.pack_start (err_label, false, true, 0);
            }

            padding.pack_start (box, false, true, 12);
            padding.halign = Align.CENTER;
            box.valign = Align.CENTER;
            box.show_all ();
        }

        private int submit_paste (out string link) {
            /* Get the values */
            string paste_code = this.controller.get_export_text ();
            string paste_name = name_entry.text;
            string paste_private = private_check.get_active () == true ? PasteBin.PRIVATE : PasteBin.PUBLIC;
            string paste_expire_date = expiry_combo.get_active_id ();

            int submit_result = PasteBin.submit (out link, paste_code, paste_name, paste_private,
                                                 paste_expire_date);

            return submit_result;
        }

        private void populate_expiry_combo () {
            expiry_combo.append (PasteBin.NEVER, _("Never"));
            expiry_combo.append (PasteBin.TEN_MINUTES, _("Ten minutes"));
            expiry_combo.append (PasteBin.HOUR, _("One hour"));
            expiry_combo.append (PasteBin.DAY, _("One day"));
            expiry_combo.append (PasteBin.MONTH, _("One month"));
        }
    }
}
