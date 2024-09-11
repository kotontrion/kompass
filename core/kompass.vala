public class Main : Object {

  private static string? get_monitor_name(Gdk.Monitor gdkmonitor) {
    Gdk.Display display = Gdk.Display.get_default();
    Gdk.Screen screen = display.get_default_screen();
    for(int i = 0; i < display.get_n_monitors(); ++i) {
      if(gdkmonitor == display.get_monitor(i)) {
        return screen.get_monitor_plug_name(i);
      }
    }
    return null;
  }
  
  private static void create_windows_for_monitor(Gdk.Monitor monitor, Config config, Astal.Application app, Kompass.ModuleManager manager) throws Kompass.ModuleError {
    string name = get_monitor_name(monitor);
    foreach( WindowConfig win_conf in config.windows) {
      if(win_conf.monitor == null) {
        app.add_window(load_window(win_conf.window, manager));
      }
      else {
        if(Regex.match_simple (win_conf.monitor, name, 0, 0)) {
          Gtk.Window win = load_window(win_conf.window, manager);
          GtkLayerShell.set_monitor(win, monitor);
          app.add_window(win);
        }
      }
    }
  }

private static string config_file;
private static bool inspector;
  
  private const GLib.OptionEntry[] options = {
      { "config", 'c', OptionFlags.NONE, OptionArg.FILENAME, ref config_file, "configuration path", "CONFIG_DIR" },
      { "inspector", 'i', OptionFlags.NONE, OptionArg.NONE, ref inspector, "open inspector", null},
      { null }
    };


  public static int main (string[] args) {

    Astal.Application app = new Astal.Application();

    try {
			var opt_context = new OptionContext ("- OptionContext example");
			opt_context.set_help_enabled (true);
			opt_context.add_main_entries (options, null);
			opt_context.parse (ref args);
		} catch (OptionError e) {
			printerr ("error: %s\n", e.message);
			printerr ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			return 1;
		}

    
    if(config_file == null)
      config_file = GLib.Environment.get_user_config_dir() + "/kompass/config.json";

    if(inspector)
      app.inspector();

    app.activate.connect(() => {

      Json.Parser parser = new Json.Parser ();


      try {
        parser.load_from_file(config_file);

        Json.Node node = parser.get_root ();

        Kompass.ModuleManager manager = new Kompass.ModuleManager();

        Config config = load_config(node, app, manager);

        if(Path.is_absolute(config.style)) {
          app.apply_css(config.style, false);
        }
        else {
          app.apply_css(Path.build_filename(Path.get_dirname(config_file), config.style), true);
        }


        app.monitors.foreach (m => {
          create_windows_for_monitor(m, config, app, manager);
        });

      } catch (Error e) {
        critical("%s\n", e.message);
        app.quit();
      }

    });

    app.hold();

    return app.run (args);  
  }
}
