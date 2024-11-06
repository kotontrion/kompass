subdir('ui')
subdir('scss')

install_data('com.github.kotontrion.kompass.gschema.xml',
  install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

compile_schemas = find_program('glib-compile-schemas', required: false, disabler: true)
test('Validate schema file',
     compile_schemas,
     args: ['--strict', '--dry-run', meson.current_source_dir()])

kompass_sources += gnome.compile_resources(
    meson.project_name(),
    'kompass.gresource.xml',
    dependencies: [blueprints, scss],
    source_dir: meson.current_build_dir(),
)

