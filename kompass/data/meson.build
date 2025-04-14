subdir('scss')
subdir('ui')

kompass_sources += gnome.compile_resources(
    'kompass-resources',
    'kompass-bar.gresource.xml',
    dependencies: [blueprints, scss],
    source_dir: meson.current_build_dir(),
    c_name: 'kompass'
)

