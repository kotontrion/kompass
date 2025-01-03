subdir('ui')
subdir('scss')

libkompass_sources += gnome.compile_resources(
    meson.project_name(),
    'libkompass.gresource.xml',
    dependencies: [blueprints, scss],
    source_dir: meson.current_build_dir(),
)


