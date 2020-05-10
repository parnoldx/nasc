libqalculate = subproject('libqalculate')
libqalculate_dep = libqalculate.get_variable('libqalculate_dep')

libqalculatenasc = static_library(
    'qalculatenasc',

    'QalculateNasc.cc',
    
    dependencies: [
        dependency('cln'),
        libqalculate_dep
    ]
)