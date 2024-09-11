deps = [
  dependency('gtk+-3.0'),
  dependency('gdk-3.0'),
  dependency('gtk-layer-shell-0'),
  dependency('astal-0.1'),
]

srcs = [
  'bar.vala',
  'clock.vala',
  'vclock.vala',
  'module.vala'
]

bar_module = shared_library('module',
  srcs,
  dependencies: deps,
  install_dir : join_paths(get_option('datadir'), 'kompass/modules/Kompass'),
  install : true)
