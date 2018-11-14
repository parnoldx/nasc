install_data(
    meson.project_name() + '.appdata.xml',
    install_dir: join_paths(get_option('prefix'), get_option('datadir'), 'metainfo')
)

install_data(
    meson.project_name() + '.desktop',
    install_dir: join_paths(get_option('prefix'), get_option('datadir'), 'applications')
)

install_data(
    meson.project_name() + '.gschema.xml',
    install_dir: schemadir,
)

#install_data(
#    'datasets/country.xml',
#    'datasets/datasetsNasc.xml',
#    install_dir: join_paths(get_option('datadir'), 'qalculate')
#)

install_data(
    'styles/def.lang',
    'styles/language.dtd',
    'styles/language.rng',
    'styles/language2.rng',
    'styles/nasc.lang',
    'styles/nasc.xml',
    'styles/styles.rng',
    install_dir: style_dir
)

