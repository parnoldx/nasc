rm build -r
rm libqalculatenasc/src -r
rm libqalculatenasc/tmp -r
rm libqalculatenasc/config.*
rm libqalculatenasc/libqalculatenasc.so
rm libqalculatenasc/librarian.sh
rm libqalculatenasc/Makefile
rm libqalculatenasc/QalculateNasc.o
mkdir build && cd build
cmake -DCMAKE_INSTALL_LIBDIR=/usr/lib -DCMAKE_INSTALL_PREFIX:PATH=/usr ..
make