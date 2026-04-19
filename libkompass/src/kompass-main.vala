namespace Kompass {
private bool is_initialized = false;

public void init() {
  if (is_initialized) {
    return;
  }

  Intl.bindtextdomain(Kompass.GETTEXT_PACKAGE, Kompass.LOCALEDIR);
  Intl.bind_textdomain_codeset(Kompass.GETTEXT_PACKAGE, "UTF-8");
  Intl.textdomain(Kompass.GETTEXT_PACKAGE);

  Adw.init();

  ensure_types();

  Gtk.CssProvider provider = new Gtk.CssProvider();
  provider.load_from_resource("net/kotontrion/libkompass/style.css");
  Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(),
                                            provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

  is_initialized = true;
}
}
