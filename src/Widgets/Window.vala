using WebKit;


public class Hello.Window : Gtk.ApplicationWindow {
    public WebView web_view;

    public Window(Application app) {
        Object (
            application: app
        );
    }

    construct {
        title = "Ordner!";
        window_position = Gtk.WindowPosition.CENTER;
        set_default_size(700, 600);

        // TODO settings aren't saved yet it seems
        var settings = new GLib.Settings("com.github.svandragt.ordner");
        // move(settings.get_int("pos-x"), settings.get_int("pos-y"));
        // set_default_size(settings.get_int("window-width"), settings.get_int("pos-x"));

        this.web_view = new WebView();
        this.web_view.load_changed.connect(onLoadChanged);
        add(web_view);

        show_all();
    }

    // Signal handler for the "clicked" signal of the button
    private void onLoadChanged() {
        title = this.web_view.title;
    }
}
