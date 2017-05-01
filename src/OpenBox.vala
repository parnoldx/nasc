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

public class OpenBox : Gtk.Box {
    private bool open_mode = false;
    private Gtk.ScrolledWindow scroll;
    private bool initialized = false;
    private Controller controller;
    private Granite.Widgets.SourceList source_list;
    private ListFooter footer;

    public signal void escape ();

    public OpenBox () {
        set_orientation (Gtk.Orientation.VERTICAL);
        this.no_show_all = true;
        scroll = new Gtk.ScrolledWindow (null, null);
        scroll.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        source_list = new Granite.Widgets.SourceList ();
        footer = new ListFooter ();

        scroll.add (source_list);
        pack_start (scroll, true, true);
        pack_end (footer, false, false);
        set_size_request (150, -1);
        this.key_press_event.connect ((e) => {
            if (e.keyval == Gdk.Key.Escape) {
                controller.input.skip_change = true;
                escape ();
                controller.input.skip_change = false;

                return true;
            } else if (e.keyval == Gdk.Key.Up) {
                var prev = source_list.get_previous_item (source_list.selected);

                if (prev != null) {
                    source_list.selected = prev;

                    return true;
                }

                return false;
            } else if (e.keyval == Gdk.Key.Down) {
                var next = source_list.get_next_item (source_list.selected);

                if (next != null) {
                    source_list.selected = next;

                    return true;
                }

                return false;
            }

            if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                if (e.keyval == Gdk.Key.o) {
                    controller.input.skip_change = true;
                    escape ();
                    controller.input.skip_change = false;

                    return true;
                } else if (e.keyval == Gdk.Key.n) {
                    on_add_sheet ();

                    return true;
                } else if (e.keyval == Gdk.Key.d) {
                    on_remove_sheet ();

                    return true;
                }
            }

            return false;
        });
        footer.add_sheet.connect (on_add_sheet);
        footer.remove_sheet.connect (on_remove_sheet);
        footer.undo.connect (on_undo_sheet);
    }

    private void on_add_sheet () {
        var sh = controller.add_sheet ();
        update ();
        source_list.selected = sh;
        source_list.start_editing_item (sh);
    }

    private void on_remove_sheet () {
        controller.remove_sheet ((source_list.selected as NascSheet));
        update ();
    }

    private void on_undo_sheet () {
        var sh = controller.actual_sheet;
        controller.undo_removal ();
        update ();
        source_list.selected = sh;
    }

    public bool is_open () {
        return open_mode;
    }

    public void open (Controller controller) {
        this.no_show_all = false;

        if (!initialized) {
            footer.controller = controller;
            setup_open_box (controller);
        }

        this.show ();
        grab_focus ();
        update ();
        this.open_mode = true;
        controller.input.source_view.editable = false;
    }

    public void close () {
        controller.input.source_view.editable = true;
        this.hide ();
        this.no_show_all = true;
        this.open_mode = false;
    }

    private void setup_open_box (Controller controller) {
        initialized = true;
        this.controller = controller;
        update ();
        source_list.item_selected.connect ((i) => {
            if (i == null) {
                return;
            }

            footer.update_ui ();
            controller.input.source_view.editable = true;

            foreach (var fav in controller.get_sheets ()) {
                if (fav == i) {
                    controller.set_sheet (fav);
                    /*
                     * fix this, time based unlock of input because it must
                     * happen after calculation thread is finished
                     */
                    GLib.Timeout.add (500, () => {
                        controller.input.source_view.editable = false;

                        return false;
                    });
                    break;
                }
            }
        });
        show_all ();
    }

    private void update () {
        var fav_sheet = controller.actual_sheet;
        source_list.root.clear ();
        source_list.grab_focus ();

        foreach (var fav in controller.get_sheets ()) {
            source_list.root.add (fav);
        }

        source_list.selected = fav_sheet;
        source_list.scroll_to_item (fav_sheet);
        footer.update_ui ();
    }
}