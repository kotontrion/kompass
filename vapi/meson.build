gir_dir = g_ir_dep.get_pkgconfig_variable('girdir')

libnma_target = custom_target('libnma-gtk4',
    command: [
        vapigen,
        gir_dir / 'NMA4-1.0.gir',
        '--library=libnma-gtk4',
        '--pkg=gtk4',
        '--pkg=libnm',
        '--directory=@0@'.format(meson.current_build_dir()),
        '--metadatadir=@0@'.format(meson.current_source_dir()),
        '--vapidir=@0@'.format(meson.current_build_dir()),
    ],
    output: 'libnma-gtk4.vapi'
)
