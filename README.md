This is a minimal example of how to build a GTK4 native app containing just a webview (WebKitGTK 6.0, Vala).

The goal is to bundle a locally-served web app into something that behaves like a native desktop app.

I don't like locally served apps to be just another browser tab, which rules out just launching the URL — even though that's simpler. Browsers like GNOME Web can install a site into the applications menu, but that requires manual user interaction per site.

## Build and run

A `Makefile` wraps the meson/ninja workflow. Defaults install under `$HOME/.local`.

```shell
make install                      # build + install binary, compile GSettings schema
make link                         # symlink ~/bin/hello-browser -> installed binary
hello-browser https://example.org
```

Both `hello-browser <url>` and `hello-browser --url <url>` are accepted. With no URL it loads `example.com`.

When running from `$HOME/.local`, `XDG_DATA_DIRS` must include `$HOME/.local/share` so the GSettings schema is discoverable. `make run` sets this for you.

## Site launcher

To register a site as a desktop application:

```shell
make desktop NAME="My App" URL=https://my-app.local:8000/ [ICON=icon-name]
```

This writes `~/.local/share/applications/hello-browser-<slug>.desktop` and refreshes the desktop database. The entry then appears in the apps menu and launches the site in its own `hello-browser` window.

## Dependencies

System packages: `meson`, `ninja-build`, `valac`, `libgtk-4-dev`, `libwebkitgtk-6.0-dev`.

![image](https://github.com/svandragt/vala-webview/assets/594871/6c9ca0fe-c8fd-48f3-afab-c11d31dcbcbf)
