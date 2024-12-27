namespace Kompass {
private bool is_initialized = false;

public void init() {
  if (is_initialized) {
    return;
  }

  Adw.init();
    string[] fake_args = new string[0];
  unowned string[] fake_unowned_args = fake_args;
  Gst.init(ref fake_unowned_args);
  ensure_types();

  Gtk.CssProvider provider = new Gtk.CssProvider();
  provider.load_from_resource("com/github/kotontrion/libkompass/style.css");
  Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(),
                                            provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);

  is_initialized = true;
}
}
