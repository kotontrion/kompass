subdir('icons')
subdir('ui')
subdir('scss')

desktop_file = i18n.merge_file(
        input: 'com.github.kotontrion.kompass.desktop.in',
       output: 'com.github.kotontrion.kompass.desktop',
         type: 'desktop',
       po_dir: '../po',
      install: true,
  install_dir: get_option('datadir') / 'applications'
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils, args: [desktop_file])
endif

appstream_file = i18n.merge_file(
        input: 'com.github.kotontrion.kompass.metainfo.xml.in',
       output: 'com.github.kotontrion.kompass.metainfo.xml',
       po_dir: '../po',
      install: true,
  install_dir: get_option('datadir') / 'metainfo'
)

appstreamcli = find_program('appstreamcli', required: false, disabler: true)
test('Validate appstream file', appstreamcli,
     args: ['validate', '--no-net', '--explain', appstream_file])

install_data('com.github.kotontrion.kompass.gschema.xml',
  install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

compile_schemas = find_program('glib-compile-schemas', required: false, disabler: true)
test('Validate schema file',
     compile_schemas,
     args: ['--strict', '--dry-run', meson.current_source_dir()])


service_conf = configuration_data()
service_conf.set('bindir', get_option('prefix') / get_option('bindir'))
configure_file(
  input: 'com.github.kotontrion.kompass.service.in',
  output: 'com.github.kotontrion.kompass.service',
  configuration: service_conf,
  install_dir: get_option('datadir') / 'dbus-1' / 'services'
)


kompass_sources += gnome.compile_resources(
    meson.project_name(),
    'kompass.gresource.xml',
    dependencies: [blueprints, scss],
    source_dir: meson.current_build_dir(),
)

