# NaSC

### Do maths like a normal person


NaSC is an app where you do maths like a normal person. It lets you type whatever you want and smartly figures out what is math and spits out an answer on the right pane. Then you can plug those answers in to future equations and if that answer changes, so does the equations it's used in.

![screenshot](Screenshot.png)



## Installation
[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.parnold-x.nasc)﻿

PPA: nasc-team/daily


```
sudo apt-add-repository ppa:nasc-team/daily
sudo apt-get update
sudo apt-get install com.github.parnold-x.nasc
```

## Building
Dependencies:

 * cmake (>= 2.8),
 * debhelper (>= 9),
 * libgcc1,
 * libqalculate-dev,
 * libgee-0.8-dev,
 * libsoup2.4-dev,
 * libglib2.0-dev (>= 2.29.0),
 * libgranite-dev (>= 0.3.0),
 * libgtk-3-dev (>=3.12),
 * libgtksourceview-3.0-dev (>=3.10),
 * valac

 
then build with:
 
```
mkdir build/ && cd build
cmake -DCMAKE_INSTALL_LIBDIR=/usr/lib -DCMAKE_INSTALL_PREFIX:PATH=/usr ..
make && sudo make install
```
