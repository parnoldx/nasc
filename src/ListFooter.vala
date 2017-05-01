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

public class ListFooter : Gtk.Toolbar {
    private Gtk.ToolButton button_add;
    private Gtk.ToolButton button_remove;
    private Gtk.ToolButton button_undo;

    public signal void add_sheet ();
    public signal void remove_sheet ();
    public signal void undo ();

    public Controller? controller;

    public ListFooter () {
        build_ui ();
    }

    private void build_ui () {
        set_style (Gtk.ToolbarStyle.ICONS);
        get_style_context ().add_class ("inline-toolbar");
        get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        get_style_context ().set_junction_sides (Gtk.JunctionSides.TOP);
        set_icon_size (Gtk.IconSize.SMALL_TOOLBAR);
        set_show_arrow (false);
        hexpand = true;

        button_add = new Gtk.ToolButton (null, _("Create new sheet"));
        button_add.set_tooltip_text (_("Create new sheet"));
        button_add.set_icon_name ("list-add-symbolic");
        button_add.clicked.connect (() => {
            add_sheet ();
        });
        insert (button_add, -1);

        button_remove = new Gtk.ToolButton (null, _("Remove sheet"));
        button_remove.set_tooltip_text (_("Remove sheet"));
        button_remove.set_icon_name ("list-remove-symbolic");
        button_remove.set_sensitive (false);
        button_remove.clicked.connect (() => {
            remove_sheet ();
        });
        insert (button_remove, -1);

        var separator = new Gtk.SeparatorToolItem ();
        separator.set_draw (false);
        separator.set_expand (true);
        insert (separator, -1);

        button_undo = new Gtk.ToolButton (null, _("Undo last sheet removal"));
        button_undo.set_tooltip_text (_("Undo last sheet removal"));
        button_undo.set_icon_name ("edit-undo-symbolic");
        button_undo.set_no_show_all (true);
        button_undo.clicked.connect (() => {
            undo ();
        });
        insert (button_undo, -1);

        update_ui ();
    }

    public void update_ui () {
        if (controller == null) {
            return;
        }

        if (controller.get_sheets ().size > 1) {
            button_remove.set_sensitive (true);
        } else {
            button_remove.set_sensitive (false);
        }

        if (controller.get_removal_list ().size == 0) {
            button_undo.set_no_show_all (true);
            button_undo.hide ();
        } else {
            button_undo.set_no_show_all (false);
        }

        show_all ();
    }
}