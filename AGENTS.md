# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

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

Four Vala source files, each one role:

- `src/Args.vala` — `Hello.Args`, the pure argument and title logic, deliberately free of GTK so the tests can link it without a display. Holds `find_class`, `resolve_app_id`, `parse` and `window_title`. Callers keep the GTK plumbing; the decisions live here.
- `src/Main.vala` — entry point. Reads `--class` / `--app-id` through `Hello.Args.find_class` and passes the value to the `Application` constructor, then calls `run`. This flag is read here, not in `command_line`, because it sets the `application_id`, which is fixed at construction — before `run`.
- `src/Application.vala` — `Gtk.Application` subclass with `HANDLES_COMMAND_LINE`. The constructor resolves the `--class` value through `Hello.Args.resolve_app_id` (validated with `GLib.Application.id_is_valid`, falling back to the default `com.github.svandragt.hello-browser` on an invalid or missing value) as both the `application_id` and `prgname`. `application_id` drives the X11 WM_CLASS res_class; `prgname` drives the WM_CLASS res_name and the Wayland app_id. A distinct `--class` therefore yields a separate instance with its own window identity. `_command_line` hands argv to `Hello.Args.parse`, which reads `--url <value>` (or a bare URL) and the `--single-instance` flag, then calls `activate()`. With `--single-instance`, `activate` raises the existing window if one exists; otherwise it creates a `Hello.Window`, calls `web_view.load_uri(...)`, and `present()`s it. Flow: `command_line` → set `url` and flags → `activate` → window construct → `load_uri` → `present`. (GTK4 has no `show_all()`, so `present()` is what actually makes the window appear.)
- `src/Widgets/Window.vala` — `Hello.Window : Gtk.ApplicationWindow` owns the `WebKit.WebView`, attached via `set_child(web_view)` (GTK4 single-child container API). The window title comes from a `bind_property` on `web_view.title` with `SYNC_CREATE`, so it follows `notify::title` and tracks later `document.title` rewrites. The transform runs the value through `Hello.Args.window_title`, which substitutes the default name for the empty string WebKit sets at `LOAD_STARTED`. Sampling the title on `load_changed` instead leaves the title bar blank: that signal is the navigation lifecycle, and the title is not part of it.

The GSettings schema (`data/gschema.xml`) defines `pos-x`, `pos-y`, `window-width`, `window-height` for persisting window geometry. `Window.construct` binds `window-width` and `window-height` to the window's `default-width`/`default-height`, so size persists across runs. `pos-x`/`pos-y` are unused — GTK4 doesn't let apps set their own window position. The schema must be installed because `Window.construct` instantiates `GLib.Settings(...)` unconditionally.

When adding new `.vala` files, list them explicitly in `src/meson.build` under the `executable(...)` sources — there is no glob.

## Tests

`make test` (or `meson test -C build`) runs `tests/ArgsTest.vala` under GLib's GTest. The test binary links `src/Args.vala` — shared with the app through the `args_sources` variable in `src/meson.build` — plus glib and gio only, so it needs no display and no WebKit.

To keep logic testable, put it in `Hello.Args` and call it from the GTK classes. Anything that needs a `Gtk.Widget` or a `WebView` is out of reach of this harness.

`Test.init` makes `g_warning` fatal. When code under test is meant to warn, claim it with `Test.expect_message(...)` before the call and `Test.assert_expected_messages()` after — don't lower the log level to keep the harness quiet.

## Releasing

Versions are tracked only as git tags and GitHub releases; there is no version string in `meson.build`. Use `MAJOR.MINOR.PATCH`: bump the minor for new features, the patch for fixes only, the major for a breaking change.

To cut a release from an up-to-date `main`:

```shell
git tag -s 0.3.0 -m 0.3.0        # signed: repo config sets tag.gpgsign
git push origin 0.3.0
gh release create 0.3.0 --title 0.3.0 --notes-file notes.md
```

The repo signs tags (`tag.gpgsign`), so a plain `git tag 0.3.0` fails with "no tag message" — always pass `-s -m`. If you run `gh release create` for a tag that doesn't exist yet, `gh` creates an unsigned tag on the remote, so tag locally first when you want it signed.

The app is used by both regular users and developers, so split the notes: put user-facing changes under `## Features` and `## Fixes`, and developer- or build-facing changes under `## For developers`. Derive them from `git log <previous-tag>..HEAD`.
