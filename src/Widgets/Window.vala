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
        set_child(web_view);
    }

    // Signal handler for the "clicked" signal of the button
    private void onLoadChanged() {
        title = this.web_view.title;
    }
}
