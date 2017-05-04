# NaSC

### Do maths like a normal person


NaSC is an app where you do maths like a normal person. It lets you type whatever you want and smartly figures out what is math and spits out an answer on the right pane. Then you can plug those answers in to future equations and if that answer changes, so does the equations its used in.

![screenshot](Screenshot.png)



## Installation
If you are using elementary OS **Loki**, in order to add a PPA you might need to first run

	sudo apt-get install software-properties-common

PPA: nasc-team/daily


```
sudo apt-add-repository ppa:nasc-team/daily
sudo apt-get update
sudo apt-get install com.github.parnold-x.nasc
```

## Building
```
mkdir build/ && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ..
make && sudo make install
```
