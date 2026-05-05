# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Minimal GTK4 native app (Vala) that wraps a WebKitGTK 6.0 `WebView`. The intent is to bundle this with a locally-served web app so it runs as a standalone desktop app rather than a browser tab.

App ID: `com.github.svandragt.hello-browser`.

## Build / Run

Meson + Ninja. Install to a user prefix to avoid `sudo`:

```shell
meson setup build --prefix="$HOME/.local"
ninja -C build install                          # installs binary + compiles GSettings schema
ninja -C build                                  # incremental rebuild
XDG_DATA_DIRS="$HOME/.local/share:$XDG_DATA_DIRS" \
    build/src/com.github.svandragt.hello-browser --url https://example.org
```

`ninja install` runs `meson/post_install.py`, which calls `glib-compile-schemas` on the installed schema dir. Without this step, constructing `GLib.Settings("com.github.svandragt.hello-browser")` in `Window.vala` will abort at runtime. Re-run `ninja install` whenever `data/gschema.xml` changes.

When running the binary from `build/`, `XDG_DATA_DIRS` must include the prefix's `share/` so GLib can locate the compiled `gschemas.compiled`. If you installed under `/usr` this is automatic; under `$HOME/.local` it usually isn't.

If you change deps in `src/meson.build`, reconfigure with `meson setup --wipe build ...` — a plain reconfigure will fail with a stale `build.dat`.

If `--url` is omitted, the app loads `https://www.example.com`. There are no tests, linter, or formatter configured.

## Dependencies

Declared in `src/meson.build`: `gtk4` and `webkitgtk-6.0`. System dev packages for both must be present.

## Architecture

Three Vala source files, each one role:

- `src/Main.vala` — entry point; instantiates `Application` and calls `run`.
- `src/Application.vala` — `Gtk.Application` subclass with `HANDLES_COMMAND_LINE`. Parses `--url <value>` manually in `_command_line`, stores it on `this.url`, then calls `activate()` which creates a `Hello.Window`, calls `web_view.load_uri(...)`, and `present()`s the window. Because the URL is read in `command_line` and consumed in `activate`, the flow is: `command_line` → set `url` → `activate` → window construct → `load_uri` → `present`. (GTK4 has no `show_all()`, so `present()` is what actually makes the window appear.)
- `src/Widgets/Window.vala` — `Hello.Window : Gtk.ApplicationWindow` owns the `WebKit.WebView`, attached via `set_child(web_view)` (GTK4 single-child container API). The window title is updated from `web_view.title` via the `load_changed` signal (so the GTK title tracks the page title as it loads).

The GSettings schema (`data/gschema.xml`) defines `pos-x`, `pos-y`, `window-width`, `window-height` for persisting window geometry, but the read/write code in `Window.vala` is currently commented out (see the `TODO settings aren't saved yet` note). The schema must still be installed because `Window.construct` instantiates `GLib.Settings(...)` unconditionally.

When adding new `.vala` files, list them explicitly in `src/meson.build` under the `executable(...)` sources — there is no glob.
