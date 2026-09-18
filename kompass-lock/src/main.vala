int main(string[] args) {
  Kompass.init();

  var provider = new Gtk.CssProvider();
  provider.load_from_resource("/net/kotontrion/kompass-lock/style.css");
  Gtk.StyleContext.add_provider_for_display(
    Gdk.Display.get_default(),
    provider,
    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
  );

  return new KompassLock.Application().run(args);
}
