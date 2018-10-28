#!/usr/bin/bash

rm -rf build

meson build --prefix=/usr

pushd build
ninja
popd

