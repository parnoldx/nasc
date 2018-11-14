#!/usr/bin/env python3

import argparse
import os
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--schemadir", action="store", required=True)
parser.add_argument("--iconsdir", action="store", required=True)

args = vars(parser.parse_args())

schemadir = args["schemadir"]
iconsdir = args["iconsdir"]

hicolordir = os.path.join(iconsdir, 'hicolor')

if not os.environ.get('DESTDIR'):
    print('Compiling gsettings schemas ...')
    subprocess.run(['glib-compile-schemas', schemadir])

    print('Compiling icon cache ...')
    subprocess.run(['gtk-update-icon-cache', hicolordir])

