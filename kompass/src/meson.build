kompass_sources += [
  'main.vala',
  'application.vala',
  'bar.vala',
  'tags.vala',
  'tray.vala',
  'clock.vala',
  'qs.vala',
  'qsAudio.vala',
  'qsAudioEndpoint.vala',
  'qsBluetooth.vala',
  'qsBluetoothDevice.vala',
  'qsButton.vala',
  'qsNotif.vala',
  'notification.vala',
  'mprisPlayer.vala',
  'cava.vala',
  'launcher.vala',
  'appButton.vala',
]

kompass_deps = [
  config_dep,
  dependency('gio-unix-2.0'),
  dependency('gtk4'),
  dependency('gtk4-layer-shell-0'),
  dependency('libadwaita-1', version: '>= 1.4'),
  dependency('libnm'),
  dependency('astal-4-4.0'),
  dependency('astal-io-0.1'),
  dependency('astal-mpris-0.1'),
  dependency('astal-river-0.1'),
  dependency('astal-tray-0.1'),
  dependency('astal-battery-0.1'),
  dependency('astal-bluetooth-0.1'),
  dependency('astal-network-0.1'),
  dependency('astal-notifd-0.1'),
  dependency('astal-cava-0.1'),
  dependency('astal-apps-0.1'),
  dependency('astal-wireplumber-0.1'),
]

types_tgt = custom_target(
  'types',
  command: [find_program('awk'), '-f', files('gen_ensure_type.awk'), '@INPUT@'],
  input: kompass_sources,
  output: 'ensure_types.vala',
  capture: true
)

kompass_sources += [types_tgt]

executable('kompass', kompass_sources,
  dependencies: kompass_deps,
  include_directories: config_inc,
  install: true,
)
