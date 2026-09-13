public static int main(string[] args) {
    // --class / --app-id must be read here, not in command_line: the app id is
    // fixed at construction (before run), and it's what gives each launcher a
    // distinct instance, WM_CLASS, and Wayland app_id for dock grouping.
    string? app_id = Hello.Args.find_class(args);
    var app = new Application(app_id);
    return app.run(args);
}
