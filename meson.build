project(
    'com.github.parnold-x.nasc',
    'vala', 'c', 'cpp',
    version: '0.5.0',
    default_options: ['cpp_std=c++11']
)

gettext_name = 'nasc'

if meson.get_compiler('vala').version() < '0.28.0'
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
    'qalculate',
    'styles'
)

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

    'libqalculatenasc/QalculateNasc.cc',
    include_directories: [include_directories('libqalculatenasc')],

    dependencies: [
        dependency('gee-0.8'),
        dependency('glib-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('gtksourceview-3.0', version: '>=3.10'),
        dependency('libsoup-2.4'),
        meson.get_compiler('c').find_library('libqalculate'),
        meson.get_compiler('vala').find_library('posix'),
        meson.get_compiler('vala').find_library('QalculateNasc', dirs: [join_paths(meson.current_source_dir(), 'vapi')])
    ],

    install: true
)

meson.add_install_script('meson/post_install.py')

subdir('data')
subdir('icons')

