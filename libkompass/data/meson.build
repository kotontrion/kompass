subdir('ui')
subdir('scss')

libkompass_sources += gnome.compile_resources(
    'libkompass-sources',
    'libkompass.gresource.xml',
    dependencies: [blueprints, scss],
    source_dir: meson.current_build_dir(),
    c_name: 'libkompass'
)


