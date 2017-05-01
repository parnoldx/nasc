CC = g++
LIBTOOL = ./libtool
DEBUG = -g
CFLAGS = -std=c++11 -fPIC -O3 -c $(DEBUG)
LFLAGS = --tag=CXX --mode=link g++ -shared

BINDIR=/home/pa/Projekte/nascOrg/build/bin
MANDIR=/home/pa/Projekte/nascOrg/build/man
LIBDIR=/home/pa/Projekte/nascOrg/build
INCDIR=/home/pa/Projekte/nascOrg/build/include/

libqalculatenasc.so : QalculateNasc.o
	$(LIBTOOL) $(LFLAGS) QalculateNasc.o -o libqalculatenasc.so -lqalculate

QalculateNasc.o : QalculateNasc.h QalculateNasc.cc
	$(CC) $(CFLAGS) QalculateNasc.cc

all: libqalculatenasc.so

clean:
	\rm -f QalculateNasc.o libqalculatenasc.so

install:
	install libqalculatenasc.so $(LIBDIR)
	install QalculateNasc.h $(LIBDIR)
