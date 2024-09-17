
project(
  'river-module',
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

module_name = 'River'



deps = [
  dependency('gtk+-3.0'),
  dependency('gdk-3.0'),
  dependency('gtk-layer-shell-0'),
  dependency('astal-0.1'),
  dependency('astal-river-0.1'),
]

srcs = [
  'title.vala',
  'tags.vala',
  'module.vala'
]

bar_module = shared_library('module',
  srcs,
  dependencies: deps,
  install_dir : join_paths(get_option('datadir'), 'kompass/modules', module_name),
  install : true)
