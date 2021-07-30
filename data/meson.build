icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data (
        join_paths ('icons', i, meson.project_name () + '.svg'),
        install_dir: join_paths (get_option ('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
    install_data (
        join_paths ('icons', i, meson.project_name () + '.svg'),
        install_dir: join_paths (get_option ('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
    )
endforeach

# Translate and install our .desktop file so the Applications Menu will see it
i18n.merge_file (
    input: meson.project_name () + '.desktop.in',
    output: meson.project_name () + '.desktop',
    po_dir: join_paths (meson.source_root (), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths (get_option ('datadir'), 'applications')
)

# Translate and install our .appdata.xml file so AppCenter will see it
i18n.merge_file (
    input: meson.project_name () + '.appdata.xml.in',
    output: meson.project_name () + '.appdata.xml',
    po_dir: join_paths (meson.source_root (), 'po', 'extra'),
    install: true,
    install_dir: join_paths (get_option ('datadir'), 'metainfo')
)

install_data(
    meson.project_name() + '.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

install_data(
    'styles/def.lang',
    'styles/language.dtd',
    'styles/language.rng',
    'styles/language2.rng',
    'styles/nasc.lang',
    'styles/nasc.xml',
    'styles/nasc_dark.xml',
    'styles/styles.rng',
    install_dir: join_paths(get_option('datadir'), 'nasc', 'styles')
)
