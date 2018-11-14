sizes = ['16', '24', '32', '48', '64', '128']

foreach size : sizes
    install_data(
        join_paths(size, meson.project_name() + '.svg'),
        install_dir: join_paths(iconsdir, 'hicolor', size + 'x' + size, 'apps')
    )
endforeach

