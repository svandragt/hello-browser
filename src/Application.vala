public class Application : Gtk.Application {
    public Application() {
        Object (
            application_id: "com.github.svandragt.hello-browser",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate() {
        var main_window = new Hello.Window(this);
        add_window(main_window);
    }
}
