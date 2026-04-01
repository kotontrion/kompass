
toml_data = configuration_data()
toml_data.set('VERSION', meson.project_version())

kompass_toml = configure_file(
  input: 'kompass.toml.in',
  output: 'kompass.toml',
  configuration: toml_data
)

subproject('gi-docgen')
gidocgen = find_program('gi-docgen', required: true)

custom_target('docs',
  input: [ kompass_toml,  gir_tgt[0] ],
  output: 'libkompass',
  command: [
    gidocgen,
    'generate',
    '--config=@INPUT0@',
    '--output-dir=@OUTPUT@',
    '--content-dir=@0@'.format(meson.current_source_dir()),
    '@INPUT1@',
  ],
)
