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


public class PeriodicTable : Gtk.Grid {
    internal class Placeholder : Gtk.DrawingArea {
        private string text;

        public Placeholder (string text) {
            this.text = text;
            set_size_request (36, 46);
        }

        public override bool draw (Cairo.Context context) {
            context.set_source_rgba (0, 0, 0, 0.1);
            context.rectangle (0, 0, 34, 44);
            context.fill ();
            context.set_source_rgba (0, 0, 0, 1);
            context.set_font_size (12);
            context.move_to (1, 38);
            context.show_text (this.text);

            return true;
        }
    }

    internal class ElementPersenter : Gtk.DrawingArea {
        private Element? el;
        private PeriodicTable table;
        private Gdk.Cursor left_ptr = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.LEFT_PTR);
        private Gdk.Cursor hand = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.HAND2);
        private bool hovering = false;
        private Gdk.Rectangle rect1 = Gdk.Rectangle ();
        private Gdk.Rectangle rect2 = Gdk.Rectangle ();
        private Gdk.Rectangle rect3 = Gdk.Rectangle ();
        private Gdk.Rectangle rect4 = Gdk.Rectangle ();

        public ElementPersenter (PeriodicTable table) {
            this.table = table;
            set_size_request (360, 138);
            this.set_events (Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.POINTER_MOTION_MASK);
            this.button_press_event.connect ((evt) => {
                if (!hovering) {
                    return false;
                }

                var src = Gdk.Rectangle ();
                src.x = (int)evt.x;
                src.y = (int)evt.y;
                src.width = 1;
                src.height = 1;

                if (rect1.intersect (src, null)) {
                    table.controller.input.insert_text ("atom(%s;%s)".printf (el.symbol, PeriodicTable.weight));
                } else if (rect2.intersect (src, null)) {
                    table.controller.input.insert_text ("atom(%s;%s)".printf (el.symbol, PeriodicTable.boiling));
                } else if (rect3.intersect (src, null)) {
                    table.controller.input.insert_text ("atom(%s;%s)".printf (el.symbol, PeriodicTable.melting));
                } else if (rect4.intersect (src, null)) {
                    table.controller.input.insert_text ("atom(%s;%s)".printf (el.symbol, PeriodicTable.density));
                } else {
                    return false;
                }

                this.get_window ().set_cursor (left_ptr);
                table.close ();

                return false;
            });
            this.motion_notify_event.connect ((evt) => {
                if (el == null) {
                    return false;
                }

                var src = Gdk.Rectangle ();
                src.x = (int)evt.x;
                src.y = (int)evt.y;
                src.width = 1;
                src.height = 1;

                if (rect1.intersect (src, null) || rect2.intersect (src, null) || rect3.intersect (src, null) ||
                    rect4.intersect (src, null)) {
                    if (!hovering) {
                        hovering = true;
                        this.get_window ().set_cursor (hand);
                    }
                } else {
                    if (hovering) {
                        hovering = false;
                        this.get_window ().set_cursor (left_ptr);
                    }
                }

                return false;
            });
        }

        public override bool draw (Cairo.Context context) {
            context.set_source_rgba (0, 0, 0, 0.1);
            draw_rounded_path (context, 0, 0, 358, 136, 10);
            context.fill ();

            if (el != null) {
                string name = table.controller.calculator.calculate
                                  (PeriodicTable.function.printf (el.index, PeriodicTable.title)).replace ("\"", "");
                Element.set_class_color (el.class, context, 1);
                draw_rounded_path (context, 10, 10, 82, 116, 10);
                context.fill ();
                context.set_source_rgba (0, 0, 0, 1);
                context.set_font_size (32);
                Cairo.TextExtents extents;
                context.text_extents (el.symbol, out extents);
                context.move_to (41 + 7 - extents.width / 2, 80);
                context.show_text (el.symbol);
                context.set_font_size (14);
                string index_str = "%d".printf (el.index);
                context.text_extents (index_str, out extents);
                context.move_to (14, 16 + extents.height);
                context.show_text (index_str);

                if (el.group > 9) {
                    context.move_to (70, 16 + extents.height);
                } else {
                    context.move_to (78, 16 + extents.height);
                }

                context.show_text ("%d".printf (el.group));
                context.move_to (78, 32 + extents.height);
                context.show_text ("%d".printf (el.period));
                context.text_extents (name, out extents);

                if (extents.width > 82) {
                    context.set_font_size (12);
                    context.text_extents (name, out extents);
                }

                context.move_to (41 + 10 - extents.width / 2, 115);
                context.show_text (name);

                /* element properties */
                context.set_font_size (14);
                string weight = table.controller.calculator.calculate
                                    (PeriodicTable.function.printf (el.index, PeriodicTable.weight));
                string weight_key = _("Weight:");
                context.text_extents (weight_key, out extents);
                int x_start = (int)(200 - extents.width);
                context.move_to (x_start, 24);
                string weight_txt = weight_key + " " + weight;
                context.show_text (weight_txt);

                if (weight != "") {
                    context.text_extents (weight_txt, out extents);
                    rect1.x = x_start;
                    rect1.y = (int)(24 - extents.height);
                    rect1.width = (int)extents.width;
                    rect1.height = (int)extents.height;
                } else {
                    rect1.x = -1;
                    rect1.y = -1;
                    rect1.width = -1;
                    rect1.height = -1;
                }

                string boiling = table.controller.calculator.calculate
                                     (PeriodicTable.function.printf (el.index, PeriodicTable.boiling));
                string boiling_key = _("Boiling Point:");
                context.text_extents (boiling_key, out extents);
                x_start = (int)(200 - extents.width);
                context.move_to (x_start, 48);
                string boiling_txt = boiling_key + " " + boiling;
                context.show_text (boiling_txt);

                if (boiling != "") {
                    context.text_extents (boiling_txt, out extents);
                    rect2.x = x_start;
                    rect2.y = (int)(48 - extents.height);
                    rect2.width = (int)extents.width;
                    rect2.height = (int)extents.height;
                } else {
                    rect2.x = -1;
                    rect2.y = -1;
                    rect2.width = -1;
                    rect2.height = -1;
                }

                string melting = table.controller.calculator.calculate
                                     (PeriodicTable.function.printf (el.index, PeriodicTable.melting));
                string melting_key = _("Melting Point:");
                context.text_extents (melting_key, out extents);
                x_start = (int)(200 - extents.width);
                context.move_to (x_start, 72);
                string melting_txt = melting_key + " " + melting;
                context.show_text (melting_txt);

                if (melting != "") {
                    context.text_extents (melting_txt, out extents);
                    rect3.x = x_start;
                    rect3.y = (int)(72 - extents.height);
                    rect3.width = (int)extents.width;
                    rect3.height = (int)extents.height;
                } else {
                    rect3.x = -1;
                    rect3.y = -1;
                    rect3.width = -1;
                    rect3.height = -1;
                }

                string density = table.controller.calculator.calculate
                                     (PeriodicTable.function.printf (el.index, PeriodicTable.density) + " to g / cm^3").
                                  replace ("(", " ").replace (")", "");
                string density_key = _("Density:");
                context.text_extents (density_key, out extents);
                x_start = (int)(200 - extents.width);
                context.move_to (x_start, 96);
                string density_txt = density_key + " " + density;
                context.show_text (density_txt);

                if (density != "") {
                    context.text_extents (density_txt, out extents);
                    rect4.x = x_start;
                    rect4.y = (int)(96 - extents.height);
                    rect4.width = (int)extents.width;
                    rect4.height = (int)extents.height;
                } else {
                    rect4.x = -1;
                    rect4.y = -1;
                    rect4.width = -1;
                    rect4.height = -1;
                }

                string classification = get_class_name (el.class);
                string classification_key = _("Classification:");
                context.text_extents (classification_key, out extents);
                context.move_to (200 - extents.width, 120);
                context.show_text (classification_key + " " + classification);
            }

            return true;
        }

        private void draw_rounded_path (Cairo.Context ctx, double x, double y,
                                        double width, double height, double radius) {
            double degrees = Math.PI / 180.0;

            ctx.new_sub_path ();
            ctx.arc (x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
            ctx.arc (x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
            ctx.arc (x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
            ctx.arc (x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
            ctx.close_path ();
        }

        public void set_element (Element? el) {
            this.el = el;
            queue_draw ();
        }

        private string get_class_name (int class) {
            switch (class) {
                case 1 :

                    return _("Alkali Metal");

                case 2 :

                    return _("Alkaline-Earth Metal");

                case 3:

                    return _("Lanthanide");

                case 4:

                    return _("Actinide");

                case 5:

                    return _("Transition Metal");

                case 6:

                    return _("Metal");

                case 7:

                    return _("Metalloid");

                case 8:

                    return _("Non-Metal");

                case 9:

                    return _("Halogen");

                case 10:

                    return _("Noble Gas");

                case 11:

                    return _("Transactinide");

                default:

                    return _("Unknown");
            }
        }
    }

    internal class Element : Gtk.DrawingArea {
        public int index { get; private set; }
        public string symbol { get; private set; }
        public int class {
            get;
            private set;
        }
        public int group { get; private set; }
        public int period { get; private set; }
        private bool focused = false;

        public Element (int index, string symbol, int class, int group, int period) {
            this.index = index;
            this.symbol = symbol;
            this.class = class;
            this.group = group;
            this.period = period;
            set_size_request (36, 46);
            add_events (Gdk.EventMask.LEAVE_NOTIFY_MASK |
                        Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.BUTTON_PRESS_MASK);
            this.enter_notify_event.connect (enter);
            this.leave_notify_event.connect (leave);
        }

        public bool enter (Gdk.EventCrossing event) {
            this.focused = true;
            queue_draw ();

            return false;
        }

        public bool leave (Gdk.EventCrossing event) {
            this.focused = false;
            queue_draw ();

            return false;
        }

        public override bool draw (Cairo.Context context) {
            if (focused) {
                set_class_color (this.class, context, 1);
            } else {
                set_class_color (this.class, context, 0.6);
            }

            /* context.rectangle (0,0,34,44); */
            draw_rounded_path (context, 0, 0, 34, 44, 4);
            context.fill ();
            context.set_source_rgba (0, 0, 0, 1);
            context.set_font_size (16);
            Cairo.TextExtents extents;
            context.text_extents (this.symbol, out extents);
            context.move_to (17 - extents.width / 2, 38);
            context.show_text (this.symbol);
            context.set_font_size (12);
            string index_str = "%d".printf (index);
            context.text_extents (index_str, out extents);
            context.move_to (2, 2 + extents.height);
            context.show_text (index_str);

            return true;
        }

        private void draw_rounded_path (Cairo.Context ctx, double x, double y,
                                        double width, double height, double radius) {
            double degrees = Math.PI / 180.0;

            ctx.new_sub_path ();
            ctx.arc (x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
            ctx.arc (x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
            ctx.arc (x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
            ctx.arc (x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
            ctx.close_path ();
        }

        public static void set_class_color (int class, Cairo.Context context, double alpha) {
            switch (class) {
                case 1:
                    context.set_source_rgba (0.9333, 0.8, 0.9333, alpha);
                    break;

                case 2:
                    context.set_source_rgba (0.86667, 0.6667, 0.9333, alpha);
                    break;

                case 3:
                    context.set_source_rgba (0.8, 0.86667, 1, alpha);
                    break;

                case 4:
                    context.set_source_rgba (0.86667, 0.9333, 1, alpha);
                    break;

                case 5:
                    context.set_source_rgba (0.8, 0.9333, 0.9333, alpha);
                    break;

                case 6:
                    context.set_source_rgba (0.7333, 1, 0.7333, alpha);
                    break;

                case 7:
                    context.set_source_rgba (0.9333, 1, 0.86667, alpha);
                    break;

                case 8:
                    context.set_source_rgba (1, 1, 0.6667, alpha);
                    break;

                case 9:
                    context.set_source_rgba (1, 0.86667, 0.6667, alpha);
                    break;

                case 10:
                    context.set_source_rgba (1, 0.8, 0.86667, alpha);
                    break;

                case 11:
                    context.set_source_rgba (0.6667, 0.9333, 0.86667, alpha);
                    break;

                default:
                    context.set_source_rgba (0, 0, 0, 0.1);
                    break;
            }
        }
    }

    public Controller controller;
    public const string function = "atom(%d;%s)";
    public const string symbol = "symbol";
    public const string number = "number";
    public const string title = "name";
    public const string class = "class"; /* A number representing an element group */
    public const string weight = "weight";
    public const string boiling = "boiling";
    public const string melting = "melting";
    public const string density = "density"; /* Density at 295K */
    public string[] elements = new string[] { "H", "He", "Li", "Be", "B", "C", "N", "O", "F", "Ne", "Na", "Mg", "Al", "Si", "P", "S",
                                              "Cl", "Ar", "K", "Ca", "Sc", "Ti", "V", "Cr", "Mn", "Fe", "Co", "Ni", "Cu", "Zn", "Ga", "Ge", "As", "Se", "Br", "Kr", "Rb", "Sr", "Y",
                                              "Zr", "Nb", "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd", "In", "Sn", "Sb", "Te", "I", "Xe", "Cs", "Ba", "La", "Ce", "Pr", "Nd", "Pm", "Sm",
                                              "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb", "Lu", "Hf", "Ta", "W", "Re", "Os", "Ir", "Pt", "Au", "Hg", "Tl", "Pb", "Bi", "Po", "At",
                                              "Rn", "Fr", "Ra", "Ac", "Th", "Pa", "U", "Np", "Pu", "Am", "Cm", "Bk", "Cf", "Es", "Fm", "Md", "No", "Lr", "Rf", "Db", "Sg", "Bh", "Hs",
                                              "Mt", "Ds", "Rg", "Uub", "Uut", "Uuq", "Uup", "Uuh", "Uus", "Uuo" };
    public int[] classification = new int[] { 8, 10, 1, 2, 7, 8, 8, 8, 9, 10, 1, 2, 6, 7, 8, 8, 9, 10, 1, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 7, 7, 8, 9,
                                              10, 1, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 7, 7, 9, 10, 1, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 7, 9, 10, 1, 2, 4,
                                              4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11 };
    private bool initialized = false;
    private ElementPersenter presenter;

    public signal void close ();

    public PeriodicTable (Controller controller) {
        this.controller = controller;
        this.presenter = new ElementPersenter (this);
        this.margin = 20;
    }

    public void init () {
        if (initialized) {
            return;
        }

        var close_but = new Gtk.Button ();
        var close_img = new Gtk.Image ();
        close_img.pixbuf = Granite.Widgets.Utils.get_close_pixbuf ();
        close_but.margin_bottom = 20;
        close_but.get_style_context ().add_class ("flat");
        close_but.set_image (close_img);
        close_but.button_press_event.connect ((evt) => {
            close ();

            return false;
        });
        attach (close_but, 0, 0, 1, 1);

        int a = 0;
        int b = 1;
        Element? element_clicked = null;

        for (int i = 0; i < elements.length; i++) {
            if (a % 18 == 0) {
                b++;
                a = 0;
            } else if (a == 1 && b == 2) {
                attach (presenter, ++a, b, 10, 3);
                a = 17;
            } else if (a == 2 && (b == 3 || b == 4)) {
                a = 12;
            } else if (a == 2 && b == 7) {
                attach (new Placeholder ("La-Lu"), a, b, 1, 1);
                b = 10;
            } else if (a == 17 && b == 10) {
                a = 3;
                b = 7;
            } else if (a == 2 && b == 8) {
                attach (new Placeholder ("Ac-Lr"), a, b, 1, 1);
                b = 11;
            } else if (a == 17 && b == 11) {
                a = 3;
                b = 8;
            }

            int group = a + 1;
            int period = b - 1;

            if (period == 9) {
                period = 6;
            }

            if (period == 10) {
                period = 7;
            }

            Element el = new Element (i + 1, elements[i], classification[i], group, period);
            el.enter_notify_event.connect ((e) => {
                presenter.set_element (el);

                return false;
            });
            el.leave_notify_event.connect ((e) => {
                presenter.set_element (element_clicked);

                return false;
            });
            el.button_press_event.connect ((e) => {
                presenter.set_element (el);
                element_clicked = el;

                return false;
            });
            attach (el, a++, b, 1, 1);
        }

        initialized = true;
        show_all ();
        this.grab_focus ();
    }
}