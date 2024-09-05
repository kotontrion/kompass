deps = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gmodule-2.0'),
  dependency('json-glib-1.0'),
  dependency('gtk+-3.0'),
  dependency('astal-0.1')
]

sources = [
  'config.vala',
  'kompass.vala',
  'moduleManager.vala',
]

executable(
  meson.project_name(),
  [sources],
  dependencies: deps,
  install: true,
)
