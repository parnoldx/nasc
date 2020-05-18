# NaSC

### Do maths like a normal person


NaSC is an app where you do maths like a normal person. It lets you type whatever you want and smartly figures out what is math and spits out an answer on the right pane. Then you can plug those answers in to future equations and if that answer changes, so does the equations it's used in.

![screenshot](Screenshot.png)



## Installation
[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.parnold-x.nasc)﻿

## Building
Dependencies:

```
apt install -y gobject-introspection libgee-0.8-dev libsoup2.4-dev libgtksourceview-3.0-dev libcln-dev libgranite-dev libcurl4-openssl-dev libmpfr-dev intltool meson valac
```

then build with:
 
```
meson build --prefix=/usr
ninja -C build install
```
