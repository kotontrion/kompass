

blueprints = custom_target('blueprints',
  input: files(
    'bar.blp',
    'qs.blp',
    'qsAudio.blp',
    'qsAudioEndpoint.blp',
    'qsBluetooth.blp',
    'qsBluetoothDevice.blp',
    'qsButton.blp',
    'qsNotif.blp',
    'notification.blp',
    'mprisPlayer.blp',
    'launcher.blp',
    'appButton.blp',
  ),
  output: '.',
  command: [
    find_program('blueprint-compiler'),
    'batch-compile',
    '--typelib-path', '@BUILD_ROOT@/subprojects/libkompass/src/',
    '@OUTPUT@',
    '@CURRENT_SOURCE_DIR@',
    '@INPUT@'
    ],
  depends: [libkompass_typelib_file]
)
