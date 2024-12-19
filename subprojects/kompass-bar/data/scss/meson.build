sass = find_program('sass')

scss_deps = files(
    'tags.scss',
    'bar.scss',
    'quicksettings.scss'
)

scss = custom_target('scss',
    input: 'main.scss',
    output: 'style.css',
    command: [
        sass, '@INPUT@', '@OUTPUT@',
    ],
    depend_files: scss_deps
)