libqalculate = subproject('libqalculate')
libqalculate_lib = libqalculate.get_variable('libqalculate_lib')

libqalculatenasc = static_library(
    'qalculatenasc',

    'QalculateNasc.cc',
    
    dependencies: [
        dependency('cln')
    ],
    link_with: libqalculate_lib
)