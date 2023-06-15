
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
    }

    public override int command_line (ApplicationCommandLine cmd) {
        // keep the application running until we are done with this commandline
        int res = _command_line (cmd);
        return res;
    }

    protected int _command_line(GLib.ApplicationCommandLine cmd) {
        // Get the arguments from the command line
        string[] arguments = cmd.get_arguments();

        // Look for the --url parameter and its value
        for (int i = 0; i < arguments.length - 1; i++) {
            if (arguments[i] == "--url") {
                this.url = arguments[i + 1];
                // Handle the URL
                // You can perform actions based on the provided URL here
                cmd.print("Received URL: " + this.url);
                break;
            }
        }

        // Proceed with the application startup
        base.command_line(cmd);
        this.activate();
        return 0;
    }
}
