
project('kompass', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 1.0.0',
  default_options: [ 'warning_level=2', 'werror=false', ],
)



targets = get_option('build_target')

subdir('libkompass')

if 'kompass' in targets or 'all' in targets
  subdir('kompass')
endif
