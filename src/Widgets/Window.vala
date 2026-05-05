using WebKit;


public class Hello.Window : Gtk.ApplicationWindow {
    public WebView web_view;

    public Window(Application app) {
        Object (
            application: app
        );
    }

    construct {
        title = "Hello Browser!";
        set_default_size(700, 600);

        // TODO settings aren't saved yet it seems
        var settings = new GLib.Settings("com.github.svandragt.hello-browser");
        // set_default_size(settings.get_int("window-width"), settings.get_int("window-height"));

        this.web_view = new WebView();
        this.web_view.load_changed.connect(onLoadChanged);
        this.web_view.create.connect(onCreate);
        set_child(web_view);
    }

    private void onLoadChanged() {
        title = this.web_view.title;
    }

    private Gtk.Widget onCreate(WebKit.NavigationAction action) {
        var uri = action.get_request().get_uri();
        if (uri != null && uri != "") {
            try {
                AppInfo.launch_default_for_uri(uri, null);
            } catch (Error e) {
                warning("Failed to open %s in default browser: %s", uri, e.message);
            }
        }
        return null;
    }
}
