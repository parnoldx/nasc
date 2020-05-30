project(
    'com.github.parnold-x.nasc',
    'vala', 'c', 'cpp',
    version: '0.6.0',
    default_options: ['cpp_std=c++11']
)

gettext_name = 'nasc'

# check vala compiler version
if meson.get_compiler('vala').version().version_compare('<0.28.0')
    error('vala compiler version 0.28.0 or newer is required.')
endif

pkg_data_dir = join_paths(
    get_option('prefix'),
    get_option('datadir'),
    'nasc'
)

style_dir = join_paths(
    get_option('prefix'),
    get_option('datadir'),
    'nasc',
    'styles'
)


# Translation module
i18n = import ('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(gettext_name),
    language: ['c', 'cpp']
)

conf_data = configuration_data()
conf_data.set('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf_data.set('STYLEDIR', style_dir)
conf_data.set('PKGDATADIR', pkg_data_dir)
conf_data.set('GETTEXT_PACKAGE', gettext_name)
conf_data.set('RELEASE_NAME', meson.project_name())
conf_data.set('VERSION', meson.project_version())
conf_data.set('VERSION_INFO', 'Release')

config_header = configure_file(
    input: 'src/config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

# build libqalculate static library
libqalculate = subproject('libqalculate')
libqalculate_dep_static = libqalculate.get_variable('libqalculate_lib_static')

# build com.github.parnold-x.nasc binary
executable(
    meson.project_name(),

    'src/Calculator.vala',
    'src/Controller.vala',
    'src/HelpBox.vala',
    'src/InputView.vala',
    'src/ListFooter.vala',
    'src/MainWindow.vala',
    'src/Nasc.vala',
    'src/NascSettings.vala',
    'src/OpenBox.vala',
    'src/PasteBinDialog.vala',
    'src/PeriodicTable.vala',
    'src/ResultBoxWidget.vala',
    'src/ResultLine.vala',
    'src/ResultView.vala',
    'src/Tutorial.vala',

    config_header,
    libqalculate.get_variable('definition_resource'),
    
    include_directories: [
        include_directories('subprojects/libqalculate/libqalculate')
    ],

    dependencies: [
        dependency('gee-0.8'),
        dependency('glib-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('gtksourceview-3.0', version: '>=3.10'),
        dependency('libsoup-2.4'),
        #dependency('cln'),
        meson.get_compiler('vala').find_library('posix'),
        meson.get_compiler('vala').find_library('QalculateNasc', dirs: [join_paths(meson.current_source_dir(), 'vapi')])
    ],

    link_with: libqalculate_dep_static,

    install: true
)

# set up post-install script

python3 = find_program('python3')

schemadir = join_paths(get_option('prefix'), get_option('datadir'), 'glib-2.0', 'schemas')
iconsdir = join_paths(get_option('prefix'), get_option('datadir'), 'icons')

meson.add_install_script(
    python3.path(),
    join_paths(meson.current_source_dir(), 'meson', 'post_install.py'),
    '--schemadir', schemadir,
    '--iconsdir', iconsdir,
)

subdir('data')
subdir('icons')
subdir('po')
