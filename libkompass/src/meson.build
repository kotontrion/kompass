version_split = meson.project_version().split('.')
version_conf = configuration_data()
version_conf.set('VERSION', meson.project_version())
version_conf.set('MAJOR_VERSION', version_split[0])
version_conf.set('MINOR_VERSION', version_split[1])
version_conf.set('MICRO_VERSION', version_split[2])

typelib = 'Kompass-' + api_version + '.typelib'
gir = 'Kompass-' + api_version + '.gir'

config = configure_file(
  input: 'config.vala.in',
  output: 'config.vala',
  configuration: {
    'API_VERSION': api_version,
    'VERSION': meson.project_version(),
    'MAJOR_VERSION': version_split[0],
    'MINOR_VERSION': version_split[1],
    'MICRO_VERSION': version_split[2],
  },
)

libkompass_vala_sources += [config] + files(
  'kompass-main.vala',

  'screenrecord.vala',

  'arrow-button.vala',
  'app-button.vala',
  'audio-endpoint.vala',
  'bluetooth-device.vala',
  'cava.vala',
  'mpris-player.vala',
  'notification.vala',
  'scrolling-label.vala',
  'tags.vala',
  'tray.vala',
  'vertical-clock.vala',
  'search-provider.vala',
  'launcher.vala',
  'search-result-button.vala',
  'wifi-ap.vala'
)

types_tgt = custom_target(
  'types',
  command: [find_program('awk'), '-f', meson.project_source_root() / 'gen_ensure_type.awk', '@INPUT@'],
  input: libkompass_vala_sources,
  output: 'ensure_types.vala',
  capture: true
)

libkompass_vala_sources += [types_tgt]

libkompass_deps += [
  dependency('libadwaita-1'),
  dependency('gio-2.0'),
  dependency('gio-unix-2.0'),
  dependency('libportal'),
  dependency('libnm'),
  dependency('gtk4'),
  dependency('libnma-gtk4'),
  dependency('astal-apps-0.1'),
  dependency('astal-bluetooth-0.1'),
  dependency('astal-io-0.1'),
  dependency('astal-cava-0.1'),
  dependency('astal-notifd-0.1'),
  dependency('astal-mpris-0.1'),
  dependency('astal-network-0.1'),
  dependency('astal-tray-0.1'),
  dependency('astal-wireplumber-0.1'),
  dependency('astal-river-0.1'),
]

libkompass_lib = shared_library('kompass',
  libkompass_sources + libkompass_vala_sources,
  dependencies: libkompass_deps + [
      meson.get_compiler('vala').find_library('posix'),
    ],
   vala_header: 'kompass.h',
     vala_vapi: 'kompass-' + api_version + '.vapi',
       version: meson.project_version(),
       install: true,
   install_dir: [true, true, true],
)

  pkgs = []
  foreach dep : libkompass_deps
    pkgs += ['--pkg=' + dep.name()]
  endforeach

  gir_tgt = custom_target(
    'gir',
    command: [find_program('python3'), files('gir.py'), meson.project_name(), gir, '@OUTPUT@']
    + pkgs
    + libkompass_vala_sources,
    input: libkompass_vala_sources,
    depends: libkompass_lib,
    output: gir,
    install: true,
    install_dir: get_option('datadir') / 'gir-1.0',
  )

libkompass_typelib_file = custom_target(
    typelib,
    command: [
      find_program('g-ir-compiler'),
      '--output', '@OUTPUT@',
      '--shared-library', get_option('prefix') / get_option('libdir') / '@PLAINNAME0@',
      '@INPUT1@'
    ],
    input: [libkompass_lib, gir_tgt[0]],
    output: typelib,
    depends: [libkompass_lib, gir_tgt],
    install: true,
    install_dir: get_option('libdir') / 'girepository-1.0',
  )

pkg = import('pkgconfig')
pkg.generate(
  description: 'A shared library for containing various widgets',
    libraries: libkompass_lib,
         name: 'libkompass',
     filebase: 'kompass-' + api_version,
      version: meson.project_version(),
      subdirs: 'kompass',
     requires: 'gio-2.0',
  install_dir: get_option('libdir') / 'pkgconfig'
)

libkompass_dep = declare_dependency(
  link_with: libkompass_lib,
  include_directories: include_directories('.')
  )
