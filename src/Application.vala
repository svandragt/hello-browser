
public class Application : Gtk.Application {
    string? url;

    public Application() {
        Object (
            application_id: "com.github.svandragt.hello-browser",
            flags: ApplicationFlags.HANDLES_COMMAND_LINE
        );
    }

    protected override void activate() {
        // Create and show the window with the specified URL
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

        // Accept either `--url <url>` or a bare positional URL argument.
        for (int i = 1; i < arguments.length; i++) {
            string arg = arguments[i];
            if (arg == "--url" && i + 1 < arguments.length) {
                this.url = arguments[i + 1];
                break;
            }
            if (arg.has_prefix("http://") || arg.has_prefix("https://")) {
                this.url = arg;
                break;
            }
        }
        if (this.url != null) {
            cmd.print("Received URL: " + this.url);
        }

        // Proceed with the application startup
        base.command_line(cmd);
        this.activate();
        return 0;
    }
}
