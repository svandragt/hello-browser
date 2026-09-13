
public class Application : Gtk.Application {
    string? url;
    bool single_instance = false;

    public Application(string? app_id = null) {
        string id = Hello.Args.resolve_app_id(app_id);
        Object (
            application_id: id,
            flags: ApplicationFlags.HANDLES_COMMAND_LINE
        );
        // Drives the Wayland app_id and the X11 WM_CLASS res_name; application_id
        // drives WM_CLASS res_class. GNOME matches StartupWMClass against either.
        GLib.Environment.set_prgname(id);
    }

    protected override void activate() {
        // With --single-instance, relaunching the same site (same --class, hence
        // same instance) raises the existing window instead of opening another.
        // Off by default: each launch opens a new window.
        if (this.single_instance) {
            var existing = this.active_window as Hello.Window;
            if (existing != null) {
                existing.present();
                return;
            }
        }

        var main_window = new Hello.Window(this);
        add_window(main_window);
        main_window.web_view.load_uri(this.url ?? "https://www.example.com");
        main_window.present();
    }

    public override int command_line (ApplicationCommandLine cmd) {
        // keep the application running until we are done with this commandline
        int res = _command_line (cmd);
        return res;
    }

    protected int _command_line(GLib.ApplicationCommandLine cmd) {
        // Get the arguments from the command line
        string[] arguments = cmd.get_arguments();

        // Accept `--url <url>` or a bare positional URL, plus the optional
        // --single-instance flag. Scan the whole line so flag order doesn't
        // matter (a .desktop Exec may list them either way).
        string? url;
        bool single_instance;
        Hello.Args.parse(arguments, out url, out single_instance);
        this.url = url;
        this.single_instance = single_instance;
        if (this.url != null) {
            cmd.print("Received URL: " + this.url);
        }

        // Proceed with the application startup
        base.command_line(cmd);
        this.activate();
        return 0;
    }
}
