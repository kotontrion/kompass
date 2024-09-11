deps = [
  dependency('gtk+-3.0'),
  dependency('astal-0.1'),
  dependency('astal-tray-0.1'),
]

srcs = [
  'tray.vala',
  'module.vala'
]

bar_module = shared_library('module',
  srcs,
  dependencies: deps,
  install_dir : join_paths(get_option('datadir'), 'kompass/modules/KompassTray'),
  install : true)
