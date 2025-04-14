

blueprints = custom_target('blueprints',
  input: files(
    'bar.blp',
    'qs.blp',
    'qsAudio.blp',
    'qsBluetooth.blp',
    'qsNotif.blp',
    'launcher.blp',
  ),
  output: '.',
  command: [
    find_program('blueprint-compiler'),
    'batch-compile',
    '--typelib-path', '@BUILD_ROOT@/libkompass/src/',
    '@OUTPUT@',
    '@CURRENT_SOURCE_DIR@',
    '@INPUT@'
    ],
  depends: [libkompass_typelib_file]
)
