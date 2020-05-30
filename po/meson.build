# Install main translations
i18n.gettext (meson.project_name (),
    args: [
        '--directory=' + meson.source_root (),
        '--from-code=UTF-8',
        '-cTRANSLATORS'
    ],
    preset: 'glib'
)

subdir ('extra')