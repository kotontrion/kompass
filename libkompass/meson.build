api_version = '0.1'
cc = meson.get_compiler('c')

# config_h = configuration_data()
# config_h.set_quoted('PACKAGE_VERSION', meson.project_version())
# config_h.set_quoted('GETTEXT_PACKAGE', 'libkompass')
# config_h.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
# configure_file(output: 'config.h', configuration: config_h)

libkompass_sources = []
libkompass_vala_sources = []
libkompass_deps = []

subdir('data')
subdir('src')

