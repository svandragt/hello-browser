args_sources = files('Args.vala')

executable(
    meson.project_name(),
    args_sources,
    'Main.vala',
    'Application.vala',

    'Widgets/Window.vala',

    dependencies: [
        dependency('gtk4'),
        dependency('webkitgtk-6.0'),
    ],
    install: true
)
