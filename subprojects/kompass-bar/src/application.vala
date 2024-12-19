class Kompass.Application : Astal.Application {
  public static Application instance;

  public override void request(string msg, SocketConnection conn) {
    AstalIO.write_sock.begin(conn, @"missing response implementation on $instance_name");
  }

  public override void activate() {
    base.activate();

    Gtk.IconTheme icon_theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default());
    icon_theme.add_resource_path("/com/github/kotontrion/kompass-bar/icons/");

    Gtk.CssProvider provider = new Gtk.CssProvider();
    provider.load_from_resource("com/github/kotontrion/kompass-bar/style.css");
    Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(), provider,
                                              Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

    AstalRiver.River river = AstalRiver.get_default();

    river.output_added.connect((riv, name) => {
      Gdk.Display.get_default().sync();
      var win = new Kompass.Bar(river.get_output(name));
      win.present();
    });

    foreach (AstalRiver.Output output in river.get_outputs()) {
      var win = new Kompass.Bar(output);
      win.present();
    }
    this.hold();
  }

  construct {
    instance_name = "kompass";
    try {
      acquire_socket();
    }
    catch (Error e) {
      printerr("%s", e.message);
    }
    instance = this;
  }
}
