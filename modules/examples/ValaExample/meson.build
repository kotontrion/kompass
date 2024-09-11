deps = [
  dependency('gtk+-3.0'),
  dependency('gtk-layer-shell-0'),
  dependency('astal-0.1')
]

bar_module = shared_library('module',
  'example.vala',
  dependencies: deps,
  install_dir : join_paths(get_option('datadir'), 'kompass/modules/ValaExample'),
  install : true)
