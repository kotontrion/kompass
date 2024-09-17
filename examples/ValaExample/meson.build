module_name = 'ValaExample'

project(
  module_name + '-module',
  'vala',
  'c',
  version: '0.1.0',
  meson_version: '>= 0.62.0',
  default_options: [
    'warning_level=2',
    'werror=false',
    'c_std=gnu11',
  ],
)



deps = [
  dependency('gtk+-3.0'),
  dependency('gtk-layer-shell-0'),
  dependency('astal-0.1')
]

bar_module = shared_library('module',
  'example.vala',
  dependencies: deps,
  install_dir : join_paths(get_option('datadir'), 'kompass/modules', module_name),
  install : true)
