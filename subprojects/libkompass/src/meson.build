api_version = '0.1'


version_split = meson.project_version().split('.')
version_conf = configuration_data()
version_conf.set('VERSION', meson.project_version())
version_conf.set('MAJOR_VERSION', version_split[0])
version_conf.set('MINOR_VERSION', version_split[1])
version_conf.set('MICRO_VERSION', version_split[2])

typelib = 'Kompass-' + api_version + '.typelib'

config = configure_file(
  input: 'config.vala.in',
  output: 'config.vala',
  configuration: {
    'VERSION': meson.project_version(),
    'MAJOR_VERSION': version_split[0],
    'MINOR_VERSION': version_split[1],
    'MICRO_VERSION': version_split[2],
  },
)

kompass_widgets_sources += [config] + files(
  'kompass-main.vala',
  
  'screenrecord.vala',

  'arrow-button.vala',
  'cava.vala',
  'tags.vala',
  'tray.vala',
  'vertical-clock.vala',
)

types_tgt = custom_target(
  'types',
  command: [find_program('awk'), '-f', files('gen_ensure_type.awk'), '@INPUT@'],
  input: kompass_widgets_sources,
  output: 'ensure_types.vala',
  capture: true
)

kompass_widgets_sources += [types_tgt]

kompass_widgets_deps = [
  dependency('libadwaita-1'),
  dependency('gio-2.0'),
  dependency('libportal'),
  dependency('astal-io-0.1'),
  dependency('astal-cava-0.1'),
  dependency('astal-tray-0.1'),
  dependency('astal-river-0.1'),

]

kompass_lib = shared_library('kompass',
  kompass_widgets_sources,
  dependencies: kompass_widgets_deps + [
      meson.get_compiler('vala').find_library('posix'),
    ],
   vala_header: 'kompass.h',
     vala_vapi: 'kompass-' + api_version + '.vapi',
      vala_gir: 'Kompass-' + api_version + '.gir',
       version: meson.project_version(),
       install: true,
   install_dir: [true, true, true, true],
)

custom_target(
    typelib,
    command: [
      find_program('g-ir-compiler'),
      '--output', '@OUTPUT@',
      '--shared-library', get_option('prefix') / get_option('libdir') / '@PLAINNAME@',
      meson.current_build_dir() / 'Kompass-' + api_version + '.gir',
    ],
    input: kompass_lib,
    output: typelib,
    depends: kompass_lib,
    install: true,
    install_dir: get_option('libdir') / 'girepository-1.0',
  )

pkg = import('pkgconfig')
pkg.generate(
  description: 'A shared library for containing various widgets',
    libraries: kompass_lib,
         name: 'libkompass',
     filebase: 'kompass-' + api_version,
      version: meson.project_version(),
      subdirs: 'kompass',
     requires: 'gio-2.0',
  install_dir: get_option('libdir') / 'pkgconfig'
)

kompass_dep = declare_dependency(
  link_with: kompass_lib,
  include_directories: include_directories('.')
  )
