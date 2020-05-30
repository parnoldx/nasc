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

internal class TutorialPage : Gtk.Box {
    private int index;
    private Tutorial stack;
    private Gtk.Button next_button;

    public signal void close ();

    public TutorialPage (Tutorial stack, string description, string content, int index) {
        this.index = index;
        this.stack = stack;
        var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        var desc = new Gtk.Label ("");
        desc.set_selectable (false);
        desc.set_line_wrap (true);
        desc.set_markup (description);
        content_box.pack_start (desc);

        var todo = new Gtk.Label ("");
        todo.set_markup (@"<b>$content</b>");
        content_box.pack_start (todo);

        /* var prev_button = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.BUTTON); */
        var close_button = new Gtk.Button.from_icon_name ("close-symbolic", Gtk.IconSize.BUTTON);
        close_button.set_relief (Gtk.ReliefStyle.NONE);
        close_button.xalign = 1;
        next_button = new Gtk.Button.from_icon_name ("go-next-symbolic", Gtk.IconSize.BUTTON);
        var button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        button_box.pack_start (close_button, false, true, 0);
        button_box.pack_start (next_button, true, true, 0);
        /* main_box.pack_start (new Gtk.Image.from_icon_name ("help-info", Gtk.IconSize.DIALOG), false, true, 0); */
        main_box.pack_start (content_box, true, true, 0);
        main_box.pack_end (button_box, false, true, 0);
        this.pack_start (main_box, true, true, 0);

        if (index == 0) {
            next_button.set_label ("Start Tutorial");
        } else if (index == 12) {
            next_button.no_show_all = true;
        }

        next_button.clicked.connect (next);
        close_button.clicked.connect (() => {
            close ();
        });
    }

    private void next () {
        stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT);
        stack.new_page (index + 1);
    }

    public void focus_button () {
        next_button.grab_focus ();
    }

    public void success () {
        next_button.set_image (new Gtk.Image.from_icon_name ("emblem-ok-symbolic", Gtk.IconSize.BUTTON));
    }
}

public class Tutorial : Gtk.Stack {
    public Controller controller;
    public signal void close ();

    public Tutorial (Controller controller) {
        this.controller = controller;
        this.set_hexpand (true);
        var page0 = new TutorialPage (this,
                                      _("Hello %s!").printf (Environment.get_real_name ()) + "\n" + _("In NaSC you can put text and math side by side and the answer will be shown on the right pane."),
                                      _("Do you want to learn the basics?"), 0);
        this.add_named (page0, "0");
        var page1 = new TutorialPage (this,
                                      _("Let's start with simple math."),
                                      _("Calculate: 11 + 42"), 1);
        this.add_named (page1, "1");
        var page2 = new TutorialPage (this,
                                      _("You can plug the answers (ans) in future equations. Just click on the answer.") + "\n"
                                      + _("If an answer changes, so does the equation it's used in."),
                                      _("Calculate: <i>ans</i> * 2"), 2);
        this.add_named (page2, "2");
        var page3 = new TutorialPage (this,
                                      _("You can also reference the last answer with the keyword \"ans\" or with \"lineX\" where X is the linenumber of the answer."),
                                      _("Calculate: sin 45° + cos 2rad (Hint: get degrees with ctrl+0)"), 3);
        this.add_named (page3, "3");
        var page4 = new TutorialPage (this,
                                      _("You can define your own variables"),
                                      _("Calculate: a = 5"), 4);
        this.add_named (page4, "4");
        var page5 = new TutorialPage (this,
                                      _("and use them in your equations"),
                                      _("Calculate: 22 + a"), 5);
        this.add_named (page5, "5");
        var page6 = new TutorialPage (this,
                                      _("You can get answers in various units"),
                                      _("Calculate: 14 cm * 3 cm"), 6);
        this.add_named (page6, "6");
        var page7 = new TutorialPage (this,
                                      _("and convert between these units"),
                                      _("Calculate: <i>ans</i> to in"), 7);
        this.add_named (page7, "7");
        var page8 = new TutorialPage (this,
                                      _("You can play with time"),
                                      _("Calculate: 3days + 4hour + 4years to ms"), 8);
        this.add_named (page8, "8");
        var page9 = new TutorialPage (this,
                                      _("or print the week of the year"),
                                      _("Calculate: week(12.12.2017)"), 9);
        this.add_named (page9, "9");
        var page10 = new TutorialPage (this,
                                       _("For a list of all those keywords and their capabilities, just open the help."),
                                       _("Calculate: The absolute value of -2 (Hint: abs)"), 10);
        this.add_named (page10, "10");
        var page11 = new TutorialPage (this,
                                       "<b>" + _("Shortcuts:") + "</b>\n<i>Ctrl + H</i> = " + _("Help") + "; <i>Ctrl + P</i> = π ; <i>Ctrl + R</i> = √ ; <i>Ctrl + L</i> = " + _("Last Answer"),
                                       _("Calculate: π * 42cm"), 11);
        this.add_named (page11, "11");
        var page12 = new TutorialPage (this,
                                       _("Great, you finished the Tutorial."),
                                       _("Have fun with NaSC"), 12);
        this.add_named (page12, "12");

        foreach (var tp in get_children ()) {
            (tp as TutorialPage).close.connect (() => {
                if (timer != -1) {
                    Source.remove (timer);
                    timer = -1;
                }

                close ();
            });
        }

        set_visible_child_name ("0");
        this.show_all ();
        /* grab focus for start tutorial button */
        Timeout.add (100, () => {
            page0.focus_button ();

            return false;
        });
    }

    uint timer = -1;
    int check_timer = 500;
    int success_timer = 1000;
    public void new_page (int index) {
        this.set_visible_child_name ("%d".printf (index));
        var old_page = this.visible_child as TutorialPage;
        controller.input.source_view.grab_focus ();

        /* timeouts to check on answers and then go to the next tut pages */
        if (timer != -1) {
            Source.remove (timer);
            timer = -1;
        }

        if (index == 1) {
            timer = GLib.Timeout.add (check_timer, () => {
                bool found = false;

                foreach (var rl in controller.results.result_list) {
                    if (rl.value == "53") {
                        found = true;
                    }
                }

                if (found) {
                    old_page.success ();
                    GLib.Timeout.add (success_timer, () => {
                        new_page (2);
                        controller.set_content ("11 + 42\n");

                        return false;
                    });
                    timer = -1;

                    return false;
                }

                return true;
            });
        }

        if (index == 2) {
            timer = GLib.Timeout.add (check_timer, () => {
                bool found = false;

                foreach (var rl in controller.results.result_list) {
                    if (rl.value == "106") {
                        found = true;
                    }
                }

                if (found) {
                    old_page.success ();
                    GLib.Timeout.add (success_timer, () => {
                        new_page (3);
                        controller.input.source_view.buffer.insert_at_cursor ("\n", -1);

                        return false;
                    });
                    timer = -1;

                    return false;
                }

                return true;
            });
        }

        if (index == 3) {
            timer = GLib.Timeout.add (check_timer, () => {
                bool found = false;

                foreach (var rl in controller.results.result_list) {
                    if (rl.value.replace (".", ",") == "0,29095994") {
                        found = true;
                    }
                }

                if (found) {
                    old_page.success ();
                    GLib.Timeout.add (success_timer, () => {
                        new_page (4);
                        controller.input.source_view.buffer.insert_at_cursor ("\n", -1);

                        return false;
                    });
                    timer = -1;

                    return false;
                }

                return true;
            });
        }

        if (index == 4) {
            timer = GLib.Timeout.add (check_timer, () => {
                bool found = false;

                foreach (var rl in controller.results.result_list) {
                    if (rl.value == "5") {
                        found = true;
                    }
                }

                if (found) {
                    old_page.success ();
                    GLib.Timeout.add (success_timer, () => {
                        new_page (5);
                        controller.input.source_view.buffer.insert_at_cursor ("\n", -1);

                        return false;
                    });
                    timer = -1;

                    return false;
                }

                return true;
            });
        }

        if (index == 5) {
            timer = GLib.Timeout.add (check_timer, () => {
                bool found = false;

                foreach (var rl in controller.results.result_list) {
                    if (rl.value == "27") {
                        found = true;
                    }
                }

                if (found) {
                    old_page.success ();
                    GLib.Timeout.add (success_timer, () => {
                        new_page (6);
                        controller.input.source_view.buffer.insert_at_cursor ("\n", -1);

                        return false;
                    });
                    timer = -1;

                    return false;
                }

                return true;
            });
        }

        if (index == 6) {
            timer = GLib.Timeout.add (check_timer, () => {
                bool found = false;

                foreach (var rl in controller.results.result_list) {
                    if (rl.value.replace (".", ",") == "0,0042 m²") {
                        found = true;
                    }
                }

                if (found) {
                    old_page.success ();
                    GLib.Timeout.add (success_timer, () => {
                        new_page (7);
                        controller.input.source_view.buffer.insert_at_cursor ("\n", -1);

                        return false;
                    });
                    timer = -1;

                    return false;
                }

                return true;
            });
        }

        if (index == 7) {
            timer = GLib.Timeout.add (check_timer, () => {
                bool found = false;

                foreach (var rl in controller.results.result_list) {
                    if (rl.value.replace (".", ",") == "6,5100130 in²") {
                        found = true;
                    }
                }

                if (found) {
                    old_page.success ();
                    GLib.Timeout.add (success_timer, () => {
                        new_page (8);
                        controller.input.source_view.buffer.insert_at_cursor ("\n", -1);

                        return false;
                    });
                    timer = -1;

                    return false;
                }

                return true;
            });
        }

        if (index == 8) {
            timer = GLib.Timeout.add (check_timer, () => {
                bool found = false;

                foreach (var rl in controller.results.result_list) {
                    if (rl.value.replace (".", ",") == "1,26504 x 10¹¹ ms") {
                        found = true;
                    }
                }

                if (found) {
                    old_page.success ();
                    GLib.Timeout.add (success_timer, () => {
                        new_page (9);
                        controller.input.source_view.buffer.insert_at_cursor ("\n", -1);

                        return false;
                    });
                    timer = -1;

                    return false;
                }

                return true;
            });
        }

        if (index == 9) {
            timer = GLib.Timeout.add (check_timer, () => {
                bool found = false;

                foreach (var rl in controller.results.result_list) {
                    if (rl.value == "50") {
                        found = true;
                    }
                }

                if (found) {
                    old_page.success ();
                    GLib.Timeout.add (success_timer, () => {
                        new_page (10);
                        controller.input.source_view.buffer.insert_at_cursor ("\n", -1);

                        return false;
                    });
                    timer = -1;

                    return false;
                }

                return true;
            });
        }

        if (index == 10) {
            timer = GLib.Timeout.add (check_timer, () => {
                bool found = false;

                foreach (var rl in controller.results.result_list) {
                    if (rl.value == "2") {
                        found = true;
                    }
                }

                if (found) {
                    old_page.success ();
                    GLib.Timeout.add (success_timer, () => {
                        new_page (11);
                        controller.input.source_view.buffer.insert_at_cursor ("\n", -1);

                        return false;
                    });
                    timer = -1;

                    return false;
                }

                return true;
            });
        }

        if (index == 11) {
            timer = GLib.Timeout.add (check_timer, () => {
                bool found = false;

                foreach (var rl in controller.results.result_list) {
                    if (rl.value.replace (".", ",") == "1,3194689 m") {
                        found = true;
                    }
                }

                if (found) {
                    old_page.success ();
                    GLib.Timeout.add (success_timer, () => {
                        new_page (12);
                        controller.input.source_view.buffer.insert_at_cursor ("\n", -1);

                        return false;
                    });
                    timer = -1;

                    return false;
                }

                return true;
            });
        }

        if (index == 12) {
            timer = GLib.Timeout.add (check_timer * 6, () => {
                close ();

                return false;
            });
        }
    }
}
