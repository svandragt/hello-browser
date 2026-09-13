namespace Hello.Args {
    const string DEFAULT_ID = "com.github.svandragt.hello-browser";

    public string? find_class(string[] args) {
        for (int i = 1; i < args.length; i++) {
            if ((args[i] == "--class" || args[i] == "--app-id") && i + 1 < args.length) {
                return args[i + 1];
            }
        }
        return null;
    }

    public string resolve_app_id(string? app_id) {
        string id = DEFAULT_ID;
        if (app_id != null) {
            if (GLib.Application.id_is_valid(app_id)) {
                id = app_id;
            } else {
                warning("Ignoring invalid --class '%s', using default id", app_id);
            }
        }
        return id;
    }

    public void parse(string[] args, out string? url, out bool single_instance) {
        url = null;
        single_instance = false;
        for (int i = 1; i < args.length; i++) {
            string arg = args[i];
            if (arg == "--single-instance") {
                single_instance = true;
            } else if (arg == "--url" && i + 1 < args.length) {
                url = args[i + 1];
            } else if (arg.has_prefix("http://") || arg.has_prefix("https://")) {
                url = arg;
            }
        }
    }

    public string window_title(string? title) {
        return (title == null || title == "") ? "Hello Browser!" : title;
    }
}
