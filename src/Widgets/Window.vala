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
        // Allow JS-driven clipboard writes (execCommand("copy") and the modern
        // Clipboard API). Off by default in WebKitGTK, which makes right-click
        // copy-link affordances silently fail in apps that wrap a webview.
        this.web_view.get_settings().javascript_can_access_clipboard = true;
        this.web_view.load_changed.connect(onLoadChanged);
        this.web_view.create.connect(onCreate);
        this.web_view.decide_policy.connect(onDecidePolicy);
        set_child(web_view);
    }

    private void onLoadChanged() {
        title = this.web_view.title;
    }

    private Gtk.Widget onCreate(WebKit.NavigationAction action) {
        openExternally(action.get_request().get_uri());
        return null;
    }

    private bool onDecidePolicy(WebKit.PolicyDecision decision, WebKit.PolicyDecisionType type) {
        if (type == WebKit.PolicyDecisionType.NEW_WINDOW_ACTION) {
            var nav = (WebKit.NavigationPolicyDecision) decision;
            openExternally(nav.get_navigation_action().get_request().get_uri());
            decision.ignore();
            return true;
        }
        return false;
    }

    private void openExternally(string? uri) {
        if (uri == null || uri == "") {
            return;
        }
        try {
            AppInfo.launch_default_for_uri(uri, null);
        } catch (Error e) {
            warning("Failed to open %s in default browser: %s", uri, e.message);
        }
    }
}
