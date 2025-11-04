class KompassBar.Application : Adw.Application {
  public static Application instance;
  private bool active = false;

  private const OptionEntry[] options = {
    { "version", 'v', OptionFlags.NONE, OptionArg.NONE, null, "Show version and exit", null },
    { "quit", 'q', OptionFlags.NONE, OptionArg.NONE, null, "quit the application", null },
    { "inspector", 'i', OptionFlags.NONE, OptionArg.NONE, null, "open the GTK inspector", null },
    { "close", 'c', OptionFlags.NONE, OptionArg.STRING_ARRAY, null, "closes a window", null },
    { "show", 's', OptionFlags.NONE, OptionArg.STRING_ARRAY, null, "shows a window", null },
    { "toggle", 't', OptionFlags.NONE, OptionArg.STRING_ARRAY, null, "toggles a window", null },
    { null }
  };

  public override int command_line(ApplicationCommandLine command_line) {
    this.hold();
    activate();

    VariantDict cmd_options = command_line.get_options_dict();

    if (cmd_options.contains("quit")) {
      quit();
    }

    if (cmd_options.contains("inspector")) {
      Gtk.Window.set_interactive_debugging(true);
    }

    var windows = new HashTable<string, Gtk.Window>(str_hash, str_equal);
    foreach (var win in this.get_windows()) {
      windows.insert(win.name, win);
    }

    foreach (var name in cmd_options.lookup_value("close", VariantType.STRING_ARRAY)?.get_strv()) {
      var win = windows.lookup(name);
      if (win == null) {
        command_line.print("window %s could not be found.\n", name);
      } else {
        win.visible = false;
      }
    }

    foreach (var name in cmd_options.lookup_value("show", VariantType.STRING_ARRAY)?.get_strv()) {
      var win = windows.lookup(name);
      if (win == null) {
        command_line.print("window %s could not be found.\n", name);
      } else {
        win.visible = true;
      }
    }

    foreach (var name in cmd_options.lookup_value("toggle", VariantType.STRING_ARRAY)?.get_strv()) {
      var win = windows.lookup(name);
      if (win == null) {
        command_line.print("window %s could not be found.\n", name);
      } else {
        win.visible = !win.visible;
      }
    }

    command_line.set_exit_status(0);
    command_line.done();
    this.release();
    return 0;
  }

  public override int handle_local_options(VariantDict cmd_options) {
    if (cmd_options.contains("version")) {
      print("kompass version %s\nlibkompass version %s\n", this.get_version(), Kompass.VERSION);
      return 0;
    }
    return -1;
  }

  public override void activate() {
    if (active) {
      return;
    }

    base.activate();

    if (AstalRiver.get_default() == null) {
      GLib.warning("could not connect to river.\n");
    }

    Gtk.CssProvider provider = new Gtk.CssProvider();
    provider.load_from_resource("com/github/kotontrion/kompass-bar/style.css");
    Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(), provider,
                                              Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

    var mons = Gdk.Display.get_default().get_monitors();
    for (var i = 0; i <= mons.get_n_items(); ++i) {
      var monitor = (Gdk.Monitor)mons.get_item(i);
      if (monitor != null) {
        var win = new KompassBar.Bar(monitor);
        win.present();
        monitor.invalidate.connect(() => win.destroy());
      }
    }

    mons.items_changed.connect((p, r, a) => {
      Gdk.Display.get_default().sync();
      for (; a > 0; a--) {
        var monitor = (Gdk.Monitor)mons.get_item(p++);
        var win = new KompassBar.Bar(monitor);
        win.present();
        monitor.invalidate.connect(() => win.destroy());
      }
    });

    new KompassBar.PopupNotificationWindow();

    this.hold();
    active = true;
  }

  construct {
    instance = this;
    flags = ApplicationFlags.HANDLES_COMMAND_LINE;

    add_main_option_entries(options);
  }
}
