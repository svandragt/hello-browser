This is a minimal example of how to build a GTK native app containing just a webview.

The goal here is to bundle this with a web app served locally into something that behaves like a native app.

I don't like locally served apps to be just another browser tab, so rules out just launching the URL, even though that's simpler.
Also some browser like Gnome Web allow the user to install the website into the applications, however this requires user interaction so is not as convenient.

```shell
# Bootstrap
meson build --prefix=/usr && cd build
ninja install

# Build and run
ninja && src/com.github.svandragt.hello-browser --url https://github.com/svandragt/vala-webview
```
![image](https://github.com/svandragt/vala-webview/assets/594871/6c9ca0fe-c8fd-48f3-afab-c11d31dcbcbf)

If you leave out the url parameter it will load example.com.
