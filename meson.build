
project('kompass', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 1.0.0',
  default_options: [ 'warning_level=2', 'werror=false', ],
)

add_project_arguments(
    '--vapidir', join_paths(meson.current_source_dir(), 'vapi'),
    language: 'vala'
)

vapigen = find_program('vapigen', required: false)
g_ir_dep = dependency('gobject-introspection-1.0', required: false)
if vapigen.found() and g_ir_dep.found()
    message('hi')
    subdir('vapi')
endif

targets = get_option('build_target')

subdir('libkompass')

if 'kompass' in targets or 'all' in targets
  subdir('kompass')
endif
