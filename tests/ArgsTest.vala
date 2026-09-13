// Headless tests for the pure argument/title logic in src/Args.vala. Nothing
// here may touch GTK: the point of the Args seam is that it runs without a
// display, so `meson test` works over SSH and in CI.

const string DEFAULT_ID = "com.github.svandragt.hello-browser";

void test_find_class() {
    string[] with_class = { "prog", "--class", "org.example.app", "https://x/" };
    assert(Hello.Args.find_class(with_class) == "org.example.app");

    string[] with_alias = { "prog", "--app-id", "org.example.app" };
    assert(Hello.Args.find_class(with_alias) == "org.example.app");

    string[] none = { "prog", "https://x/" };
    assert(Hello.Args.find_class(none) == null);

    // Trailing flag with no value must not read past the end of argv.
    string[] dangling = { "prog", "--class" };
    assert(Hello.Args.find_class(dangling) == null);
}

void test_resolve_app_id() {
    assert(Hello.Args.resolve_app_id(null) == DEFAULT_ID);
    assert(Hello.Args.resolve_app_id("org.example.app") == "org.example.app");

    // Invalid ids fall back rather than crashing GApplication at construction,
    // and say so. Test.init makes g_warning fatal, so each one must be claimed
    // up front; assert_expected_messages then fails if it never arrived.
    Test.expect_message(null, LogLevelFlags.LEVEL_WARNING, "*Ignoring invalid*");
    assert(Hello.Args.resolve_app_id("not a valid id!") == DEFAULT_ID);
    Test.expect_message(null, LogLevelFlags.LEVEL_WARNING, "*Ignoring invalid*");
    assert(Hello.Args.resolve_app_id("") == DEFAULT_ID);
    Test.assert_expected_messages();
}

void test_parse() {
    string? url;
    bool single;

    string[] bare = { "prog", "https://example.org/" };
    Hello.Args.parse(bare, out url, out single);
    assert(url == "https://example.org/");
    assert(single == false);

    string[] flagged = { "prog", "--url", "http://127.0.0.1:7655/" };
    Hello.Args.parse(flagged, out url, out single);
    assert(url == "http://127.0.0.1:7655/");

    // Flag order must not matter: a .desktop Exec may list them either way.
    string[] before = { "prog", "--single-instance", "https://example.org/" };
    Hello.Args.parse(before, out url, out single);
    assert(url == "https://example.org/");
    assert(single == true);

    string[] after = { "prog", "https://example.org/", "--single-instance" };
    Hello.Args.parse(after, out url, out single);
    assert(single == true);

    string[] nothing = { "prog" };
    Hello.Args.parse(nothing, out url, out single);
    assert(url == null);
    assert(single == false);
}

void test_window_title() {
    // Regression: WebKit clears the title to "" at LOAD_STARTED, which used to
    // leave the window title bar blank.
    assert(Hello.Args.window_title(null) == "Hello Browser!");
    assert(Hello.Args.window_title("") == "Hello Browser!");
    assert(Hello.Args.window_title("herdr board") == "herdr board");
}

int main(string[] args) {
    Test.init(ref args);
    Test.add_func("/args/find-class", test_find_class);
    Test.add_func("/args/resolve-app-id", test_resolve_app_id);
    Test.add_func("/args/parse", test_parse);
    Test.add_func("/args/window-title", test_window_title);
    return Test.run();
}
