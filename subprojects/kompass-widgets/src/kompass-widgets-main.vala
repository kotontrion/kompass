namespace Kompass {
private bool is_initialized = false;

public void init() {
  if (is_initialized) {
    return;
  }

  Adw.init();

  ensure_types();

  Gtk.CssProvider provider = new Gtk.CssProvider();
  provider.load_from_resource("com/github/kotontrion/kompass-widgets/style.css");
  Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(),
                                            provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);

  is_initialized = true;
}
}
