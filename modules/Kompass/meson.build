deps = [
  dependency('gtk+-3.0'),
  dependency('gdk-3.0'),
  dependency('gtk-layer-shell-0'),
  dependency('astal-0.1'),
  dependency('astal-battery-0.1'),
  dependency('astal-bluetooth-0.1'),
  dependency('astal-network-0.1'),
  dependency('libnm'),
]

srcs = [
  'bar.vala',
  'clock.vala',
  'vclock.vala',
  'quicksettings.vala',
  'module.vala'
]

bar_module = shared_library('module',
  srcs,
  dependencies: deps,
  install_dir : join_paths(get_option('datadir'), 'kompass/modules/Kompass'),
  install : true)
