blueprints = custom_target('blueprints',
  input: files(
    'app-button.blp',
    'arrow-button.blp',
    'audio-endpoint.blp',
    'bluetooth-device.blp',
    'notification.blp',
    'mpris-player.blp',
    'vertical-clock.blp',
    'search-result-button.blp',
    'search-result-provider.blp',
    'wifi-ap.blp'
  ),
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)
