namespace Kompass {
[GtkTemplate(ui = "/com/github/kotontrion/libkompass/ui/result-provider.ui")]
public class ResultProvider : Gtk.Box {
  [GtkChild]
  private unowned Gtk.Revealer revealer;
  [GtkChild]
  private unowned Gtk.ListBox results;

  public SearchProvider provider { get; private set; }
  private Gtk.SliceListModel result_model;

  private Gtk.Widget result_button_factory(Object item) {
    return new SearchResultButton(item as Kompass.SearchResult);
  }

  public ResultProvider(SearchProvider provider) {
    this.provider = provider;
    this.result_model = new Gtk.SliceListModel(this.provider.results, 0, 5);
    this.results.bind_model(this.result_model, result_button_factory);
  }

  public async void search(string query) {
    yield this.provider.search(query);

    this.revealer.reveal_child = this.provider.results.get_n_items() > 0;
  }
}

public class Launcher : Gtk.Box {
  private ResultProvider[] providers;
  private string[] enabled_providers = {
    "org.gnome.Calculator-search-provider.ini",
    "org.gnome.Calendar.search-provider.ini",
    "org.gnome.Contacts.search-provider.ini",
    "org.gnome.Nautilus.search-provider.ini"
  }; //TODO make this configurable, or read from gsettings

  construct {
    this.orientation = Gtk.Orientation.VERTICAL;
    providers = new ResultProvider[0];
    setup_provider.begin();
  }

  public async void search(string query) {
    foreach (var provider in providers) {
      provider.search.begin(query);
    }
  }

  private async void setup_provider() {
    var apps = new ResultProvider(new AppSearchProvider());

    this.append(apps);
    this.providers += apps;

    string dir_path = "/usr/share/gnome-shell/search-providers/";

    try {
      File dir = File.new_for_path(dir_path);
      string? file_name;
      foreach (string file in enabled_providers) {
        var file_path = dir.get_child(file).get_path();

        if (!FileUtils.test(file_path, FileTest.EXISTS)) {
          continue;
        }

        KeyFile keyfile = new KeyFile();
        keyfile.load_from_file(file_path, KeyFileFlags.NONE);

        string desktop_id = keyfile.get_string("Shell Search Provider", "DesktopId");
        string bus_name = keyfile.get_string("Shell Search Provider", "BusName");
        string object_path = keyfile.get_string("Shell Search Provider", "ObjectPath");
        int version = keyfile.get_integer("Shell Search Provider", "Version");

        if (version != 2) {
          continue;
        }

        var p = new ResultProvider(yield new DBusSearchProvider(bus_name, object_path));
        this.append(p);
        this.providers += p;
      }
    } catch (Error e) {
      stderr.printf("Failed to open directory %s: %s\n", dir_path, e.message);
    }
  }
}
}
