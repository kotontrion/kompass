kompass_lock_sources = files(
  'application.vala',
  'lockscreen.vala',
  'main.vala',
  'window.vala',
)

executable('kompass-lock',
  kompass_lock_sources + kompass_lock_resources,
  dependencies: libkompass_deps + [
    libkompass_dep,
    dependency('astal-auth-0.1'),
    dependency('astal-battery-0.1'),
    dependency('astal-brightness-0.1'),
    dependency('astal-mpris-0.1'),
  ],
  c_args: ['-DGETTEXT_PACKAGE="kompass"'],
  install: true,
)
