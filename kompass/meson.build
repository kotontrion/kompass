
i18n = import('i18n')
gnome = import('gnome')
valac = meson.get_compiler('vala')


#config_h = configuration_data()
#config_h.set_quoted('PACKAGE_VERSION', meson.project_version ())
#config_h.set_quoted('GETTEXT_PACKAGE', 'kompass')
#config_h.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
#configure_file(output: 'config.h', configuration: config_h)

#config_dep = valac.find_library ('config', dirs: 'src')
#config_inc = include_directories('.')


#config = configure_file(
#  input: 'config.vala.in',
#  output: 'config.vala',
#  configuration: {
#    'GETTEXT_PACKAGE': 'kompass',
#    'LOCALEDIR': get_option('prefix') / get_option('localedir'),
#    'PACKAGE_VERSION': meson.project_version (),
#  },
#)

#add_project_arguments('-DGETTEXT_PACKAGE="' + meson.project_name () + '"', language: 'c')

kompass_sources = []
kompass_vala_sources = []

subdir('data')
subdir('po')
subdir('src')
