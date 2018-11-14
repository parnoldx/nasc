#!/usr/bin/bash

rm -rf build

meson build --prefix=/usr

ninja -C build

