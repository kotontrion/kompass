subdir('scss')
subdir('ui')

kompass_lock_resources = gnome.compile_resources(
  'kompass-lock-resources',
  'kompass-lock.gresource.xml',
  dependencies: [kompass_lock_blueprints, kompass_lock_scss],
  source_dir: meson.current_build_dir(),
  c_name: 'kompass_lock'
)
