# Project name, programming language and version
project (
    'com.github.parnold-x.nasc',
    'vala', 'c', 'cpp',
    version: '0.7.6',
    default_options: ['cpp_std=c++11']
)

# Check vala compiler version
if meson.get_compiler ('vala').version ().version_compare ('<0.28.0')
    error ('vala compiler version 0.28.0 or newer is required.')
endif

# Translation module
i18n = import ('i18n')

# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    language: ['c', 'cpp']
)

conf_data = configuration_data ()
conf_data.set ('STYLEDIR', join_paths (get_option ('prefix'), get_option ('datadir'), 'nasc', 'styles'))

config_header = configure_file (
    input: 'src/Config.vala.in',
    output: 'Config.vala',
    configuration: conf_data
)

# Listing dependencies
dependencies = [
    dependency ('gee-0.8'),
    dependency ('glib-2.0'),
    dependency ('granite'),
    dependency ('gtk+-3.0'),
    dependency ('gtksourceview-3.0', version: '>=3.10'),
    dependency ('webkit2gtk-4.0'),
    #dependency ('cln'),
    meson.get_compiler ('vala').find_library ('posix'),
    meson.get_compiler ('vala').find_library ('QalculateNasc', dirs: [join_paths (meson.current_source_dir (), 'vapi')])
]

# Build libqalculate static library
libqalculate = subproject ('libqalculate')
libqalculate_dep_static = libqalculate.get_variable ('libqalculate_lib_static')

subdir('src')

# Build com.github.parnold-x.nasc binary
executable (
    meson.project_name (),

    sources,

    config_header,

    libqalculate.get_variable('definition_resource'),
    
    include_directories: [
        include_directories('subprojects/libqalculate/libqalculate')
    ],

    dependencies: dependencies,

    link_with: libqalculate_dep_static,

    install: true
)

subdir('data')
subdir('po')

meson.add_install_script ('meson/post_install.py')
