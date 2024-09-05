public class Main : Object {

  private static string config_file;
  
  private const GLib.OptionEntry[] options = {
      { "config", 'c', OptionFlags.NONE, OptionArg.FILENAME, ref config_file, "configuration file", "CONFIG_FILE" },
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

    app.activate.connect(() => {

      Json.Parser parser = new Json.Parser ();


      try {
        parser.load_from_file(config_file);

        Json.Node node = parser.get_root ();

        Kompass.ModuleManager manager = new Kompass.ModuleManager();

        process (node, manager);
      } catch (Error e) {
        critical("%s\n", e.message);
        app.quit();
      }

    });

    app.hold();

    return app.run (args);  
  }
}
