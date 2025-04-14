

config = configure_file(
  input: 'config.vala.in',
  output: 'config.vala',
  configuration: {
    'GETTEXT_PACKAGE': 'kompass',
    'LOCALEDIR': get_option('prefix') / get_option('localedir'),
    'PACKAGE_VERSION': meson.project_version (),
  },
)

kompass_vala_sources += [config] + [
  'main.vala',
  'application.vala',
  'bar.vala',
  'qs.vala',
  'qsAudio.vala',
  'qsBluetooth.vala',
  'qsNotif.vala',
  'launcher.vala',
]

kompass_deps = [
  libkompass_dep,
  dependency('gio-unix-2.0'),
  dependency('gtk4'),
  dependency('gtk4-layer-shell-0'),
  dependency('libadwaita-1', version: '>= 1.4'),
  dependency('libnm'),
  dependency('astal-4-4.0'),
  dependency('astal-io-0.1'),
  dependency('astal-mpris-0.1'),
  dependency('astal-river-0.1'),
  dependency('astal-battery-0.1'),
  dependency('astal-bluetooth-0.1'),
  dependency('astal-network-0.1'),
  dependency('astal-notifd-0.1'),
  dependency('astal-apps-0.1'),
  dependency('astal-wireplumber-0.1'),
]

types_tgt = custom_target(
  'types',
  command: [find_program('awk'), '-f', meson.project_source_root() / 'gen_ensure_type.awk', '@INPUT@'],
  input: kompass_vala_sources,
  output: 'ensure_types.vala',
  capture: true
)

kompass_vala_sources += [types_tgt]

executable('kompass', kompass_vala_sources + kompass_sources,
  dependencies: kompass_deps,
  c_args: ['-DGETTEXT_PACKAGE="kompass"'],
  install: true,
)
