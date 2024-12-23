subdir('ui')
subdir('scss')

kompass_sources += gnome.compile_resources(
    meson.project_name(),
    'kompass-bar.gresource.xml',
    dependencies: [blueprints, scss],
    source_dir: meson.current_build_dir(),
)

