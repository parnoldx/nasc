#!/usr/bin/python3

import os
import subprocess

schemadir = os.path.join(os.environ['MESON_INSTALL_PREFIX'],
                         'share', 'glib-2.0', 'schemas')

hicolordir = os.path.join(os.environ['MESON_INSTALL_PREFIX'],
                          'icons', 'hicolor')

if not os.environ.get('DESTDIR'):
    print('Compiling gsettings schemas ...')
    subprocess.run(['glib-compile-schemas', schemadir])

    print('Compiling icon cache ...')
    subprocess.run(['gtk-update-icon-cache', hicolordir])

