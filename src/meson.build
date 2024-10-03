kompass_sources += [
  'main.vala',
  'application.vala',
  'bar.vala',
  'tags.vala',
  'clock.vala',
  'qs.vala',
  'qsAudio.vala',
  'qsAudioEndpoint.vala',
  'qsBluetooth.vala',
  'qsBluetoothDevice.vala',
  'qsButton.vala',
]

kompass_deps = [
  config_dep,
  dependency('gtk4'),
  dependency('gtk4-layer-shell-0'),
  dependency('libadwaita-1', version: '>= 1.4'),
  dependency('libnm'),
  dependency('astal-river-0.1'),
  dependency('astal-battery-0.1'),
  dependency('astal-bluetooth-0.1'),
  dependency('astal-network-0.1'),
  dependency('astal-wireplumber-0.1'),
]

executable('kompass', kompass_sources,
  dependencies: kompass_deps,
  include_directories: config_inc,
  install: true,
)
