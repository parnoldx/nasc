<div align="center">
  <span align="center"> <img width="80" height="80" class="center" src="https://raw.githubusercontent.com/parnold-x/nasc/master/icons/128/com.github.parnold_x.nasc.svg" alt="Icon"></span>
  <h1 align="center">NaSC</h1>
  <h3 align="center">Do maths like a normal person</h3>
</div>

![screenshot](Screenshot.png)

NaSC is an app where you do maths like a normal person. It lets you type whatever you want and smartly figures out what is math and spits out an answer on the right pane. Then you can plug those answers in to future equations and if that answer changes, so does the equations it's used in.

## Installation
[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.parnold-x.nasc)﻿

## Building

Dependencies(Debian/Ubuntu):

```bash
apt install -y gobject-introspection libgee-0.8-dev libwebkit2gtk-4.0-dev libgtksourceview-3.0-dev libcln-dev libgranite-dev libcurl4-openssl-dev libmpfr-dev intltool meson valac
```

Dependencies(Fedora/CentOS):

```bash
dnf install gobject-introspection libgee-devel webkit2gtk3-devel gtksourceview3-devel cln-devel granite-devel libcurl-devel mpfr-devel intltool meson vala 
```

then build with:
 
```bash
meson build --prefix=/usr
ninja -C build install
```
