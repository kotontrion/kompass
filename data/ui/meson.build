blueprints = custom_target('blueprints',
  input: files(
    'bar.blp',
    'clock.blp',
    'qs.blp',
    'qsAudio.blp',
    'qsAudioEndpoint.blp',
  ),
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)
