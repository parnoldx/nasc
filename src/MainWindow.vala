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
    /* UI constants */
    public const int left_margin = 12;
    public const int vertical_padding = 8;
    public const int top_padding = 10;

    public class MainWindow : Gtk.Window {
        private NascApp app;
        private Gtk.Paned pane;
        private Controller controller;
        private InputView input_box;
        private ResultView result_box;
        // private OpenBox open_box;
        private HelpBox help_box;
        private PeriodicTable periodic_box;
        // private Gtk.ToggleButton open_button;
        private Gtk.ToggleButton help_button;
        private Gtk.Stack main_stack;
        private Gtk.Stack right_stack;

        public MainWindow (NascApp app) {
            this.app = app;
            this.set_application (app);
            this.icon_name = "nasc";

            int x = NascSettings.get_instance ().opening_x;
            int y = NascSettings.get_instance ().opening_y;

            if (x != -1 && y != -1) {
                move (x, y);
            } else {
                x = (Gdk.Screen.width () - default_width) / 2;
                y = (Gdk.Screen.height () - default_height) / 2;
                move (x, y);
            }

            /* Set window properties */
            this.set_default_size (NascSettings.get_instance ().window_width, NascSettings.get_instance ().window_height);

            this.delete_event.connect (on_window_closing);

            /* Create the toolbar */
            var toolbar = new Gtk.HeaderBar ();
            toolbar.set_title (app.program_name);
            this.set_titlebar (toolbar);
            toolbar.show_close_button = true;
            // open_button = new Gtk.ToggleButton ();
            // open_button.set_image (new Gtk.Image.from_icon_name ("document-open", Gtk.IconSize.LARGE_TOOLBAR));
            // open_button.set_tooltip_markup ("Open sheets");
            help_button = new Gtk.ToggleButton ();
            help_button.set_image (new Gtk.Image.from_icon_name ("help-contents", Gtk.IconSize.LARGE_TOOLBAR));
            help_button.set_tooltip_markup ("Open help");
            var export_button = new Gtk.Button.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
            export_button.set_tooltip_markup ("Export…");
            var export_popover = new Gtk.Popover (export_button);

            var pdf_button = new Gtk.Button.with_label (_("Export to PDF"));
            pdf_button.get_style_context ().add_class ("flat");
            pdf_button.margin = 5;

            var share_button = new Gtk.Button.with_label (_("Share via PasteBin"));
            share_button.get_style_context ().add_class ("flat");
            share_button.margin = 5;
            share_button.margin_top = 0;

            var export_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            export_box.pack_start (pdf_button, true, true, 0);
            export_box.pack_start (share_button, true, true, 0);

            export_popover.add (export_box);
            export_button.clicked.connect (() => {
                export_popover.show_all ();
            });

            /* var setting_button = new Gtk.Button.from_icon_name("document-properties", Gtk.IconSize.LARGE_TOOLBAR); */
            // toolbar.pack_start (open_button);
            /* TODO settings ? */
            toolbar.pack_end (export_button);
            toolbar.pack_end (help_button);

            main_stack = new Gtk.Stack ();
            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            main_stack.add_named (main_box, "main");
            this.add (main_stack);

            var info_bar = new Gtk.InfoBar ();
            info_bar.set_message_type (Gtk.MessageType.QUESTION);
            info_bar.no_show_all = true;
            info_bar.hide ();
            main_box.pack_start (info_bar, false, true, 0);

            right_stack = new Gtk.Stack ();

            // open_box = new OpenBox ();

            input_box = new InputView ();
            result_box = new ResultView ();

            var content_pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            content_pane.set_position (150);
            right_stack.add_named (result_box, "result");
            pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            pane.expand = true;
            pane.pack1 (input_box, true, false);
            pane.pack2 (right_stack, true, false);
            pane.set_position (NascSettings.get_instance ().pane_position);
            var scroll = new Gtk.ScrolledWindow (null, null);
            scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            /* scroll to the last entry when scroll is needed */
            input_box.size_allocate.connect ((alloc) => {
                var v_adjust = scroll.get_vadjustment ();
                v_adjust.set_value (v_adjust.upper - v_adjust.page_size);
            });
            scroll.add (pane);

            // content_pane.pack1 (open_box, true, false);
            content_pane.pack2 (scroll, true, false);
            main_box.pack_start (content_pane, true, true, 0);

            controller = new Controller (input_box, result_box);
            help_box = new HelpBox (controller);
            right_stack.add_named (help_box, "help");

            periodic_box = new PeriodicTable (controller);
            periodic_box.close.connect (() => {
                main_stack.set_visible_child (main_box);
                input_box.source_view.grab_focus ();
            });

            main_stack.add_named (periodic_box, "periodic");

            pane.notify["position"].connect ((s, p) => {
                result_box.set_width (pane.get_allocated_width () - pane.position - 1);
            });

            // open_button.toggled.connect (open_toggle);
            help_button.toggled.connect (help_toggle);

            // input_box.open.connect (open_toggle);

            input_box.new_trigger.connect (() => {
                // if (!open_box.is_open ()) {
                    controller.add_sheet ();
                    result_box.clear ();
                // }
            });

            // input_box.escape.connect (() => {
            //     if (open_box.is_open ()) {
            //         open_button.set_active (false);
            //         close_open ();
            //     }
            // });
            input_box.help.connect (() => {
                help_button.active = !help_button.active;
                help_toggle ();
            });
            input_box.quit.connect (() => {
                app.quit();
            });
            help_box.close_help.connect (() => {
                help_button.active = !help_button.active;
                help_toggle ();
            });
            // open_box.escape.connect (() => {
            //     if (open_box.is_open ()) {
            //         open_button.set_active (false);
            //         close_open ();
            //     }
            // });

            pdf_button.clicked.connect (() => {
                export_popover.hide ();
                var sh = controller.actual_sheet.name;
                Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
                    "Choose a PDF save location", this, Gtk.FileChooserAction.SAVE,
                    "_Cancel",
                    Gtk.ResponseType.CANCEL,
                    "_Save",
                    Gtk.ResponseType.ACCEPT);
                chooser.set_current_name ("%s.pdf".printf (sh));

                if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                    SList<string> uris = chooser.get_uris ();

                    foreach (unowned string uri in uris) {
                        var canvas = new Cairo.PdfSurface (Uri.unescape_string (uri.replace ("file://", "")),
                                                           pane.get_allocated_width (), pane.get_allocated_height ());
                        var cr = new Cairo.Context (canvas);
                        pane.draw (cr);
                        canvas.finish ();
                    }
                }

                chooser.close ();
            });

            share_button.clicked.connect (() => {
                export_popover.hide ();
                new PasteBinDialog (this, controller);
            });

            controller.tutorial.connect (() => {
                GLib.Timeout.add (10, () => {
                    input_box.delete_characters (10);

                    return false;
                });
                show_tutorial (info_bar);
            });

            controller.periodic.connect (() => {
                GLib.Timeout.add (10, () => {
                    input_box.delete_characters (6);

                    return false;
                });
                periodic_box.init ();
                main_stack.set_visible_child (periodic_box);
            });

            show_all ();

            GLib.Timeout.add (500, () => {
                if (NascSettings.get_instance ().show_tutorial) {
                    show_tutorial (info_bar);
                }

                return false;
            });

            /* update width */
            result_box.set_width (pane.get_allocated_width () - pane.position - 1);
        }

        private void show_tutorial (Gtk.InfoBar info_bar) {
            Gtk.Container content = info_bar.get_content_area ();

            foreach (var w in content.get_children ()) {
                w.destroy ();
            }

            var tut = new Tutorial (controller);
            content.add (tut);
            tut.close.connect (() => {
                info_bar.no_show_all = true;
                info_bar.hide ();
            });
            info_bar.no_show_all = false;
            info_bar.show_all ();
        }

        // private void open_toggle () {
        //     if (!open_box.is_open ()) {
        //         open_button.set_active (true);
        //         open_box.open (controller);
        //         right_stack.hide ();
        //     } else {
        //         close_open ();
        //     }
        // }

        private void help_toggle () {
            if (help_button.active) {
                right_stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT);
                right_stack.set_visible_child_name ("help");
                help_box.search_focus ();
            } else {
                right_stack.set_transition_type (Gtk.StackTransitionType.SLIDE_RIGHT);
                right_stack.set_visible_child_name ("result");
                input_box.source_view.grab_focus ();
            }
        }

        // private void close_open () {
        //     open_button.set_active (false);
        //     open_box.close ();
        //     right_stack.show_all ();
        //     input_box.source_view.grab_focus ();
        // }

        /*
         * Saves the window height and width before closing
         */
        private bool on_window_closing () {
            int width, height;
            this.get_size (out width, out height);
            NascSettings.get_instance ().window_height = height;
            NascSettings.get_instance ().window_width = width;

            int pane_width;
            pane_width = pane.get_position ();
            NascSettings.get_instance ().pane_position = pane_width;

            /* Save window position */
            int root_x, root_y;
            get_position (out root_x, out root_y);
            NascSettings.get_instance ().opening_x = root_x;
            NascSettings.get_instance ().opening_y = root_y;

            if (NascSettings.get_instance ().show_tutorial) {
                NascSettings.get_instance ().show_tutorial = false;
            }

            controller.store_sheet_content ();

            return false;
        }
    }
}