using WebKit;


public class Hello.Window : Gtk.ApplicationWindow {

    private WebView web_view;

    public Window(Application app) {
        Object (
            application: app
        );
    }

    construct {
        title = "This is my vala test";
        window_position = Gtk.WindowPosition.CENTER;
        set_default_size(350, 300);

        var settings = new GLib.Settings("com.github.svandragt.hello-browser");
        move(settings.get_int("pos-x"), settings.get_int("pos-y"));

        this.web_view = new WebView();
        add(web_view);

        show_all();
        this.web_view.load_uri("https://vandragt.com");

    }
}
