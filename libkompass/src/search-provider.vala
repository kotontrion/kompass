public class Kompass.SearchResult : Object {
  public string id { get; set; }
  public string name { get; set; }
  public string description { get; set; }
  public Icon icon { get; set; }

  public delegate void ActivateResult(SearchResult result);

  private ActivateResult activate_fun;

  public void set_activate_fun(owned ActivateResult activate_fun) {
    this.activate_fun = (owned)activate_fun;
  }

  public void activate() {
    this.activate_fun(this);
  }

  internal static SearchResult from_dbus_data(HashTable<string, Variant> meta, owned ActivateResult activate) {
    var result = new SearchResult();

    var id = meta.lookup("id");

    if (id != null) {
      result.id = id.get_string();
    } else {
      result.id = "";
    }

    var name = meta.lookup("name");
    if (name != null) {
      result.name = name.get_string();
    } else {
      result.name = "";
    }

    var description = meta.lookup("description");
    if (description != null) {
      result.description = description.get_string();
    } else {
      result.description = "";
    }

    var icon = meta.lookup("icon");
    var icon_data = meta.lookup("icon-data");
    if (icon != null) {
      result.icon = Icon.deserialize(icon);
    } else if (icon_data != null) {
      int width, height, rowstride, bits_per_sample, n_channels;
      bool has_alpha;
      Bytes bytes;

      Variant data;

      icon_data.get("(iiibii@ay)", out width, out height, out rowstride, out has_alpha, out bits_per_sample, out n_channels, out data);
      bytes = new Bytes(data.get_data_as_bytes().get_data());

      //result.icon = new Gdk.Pixbuf.from_bytes(bytes, Gdk.Colorspace.RGB, has_alpha, bits_per_sample, width, height, rowstride);
      result.icon = new Gdk.MemoryTexture(width, height, has_alpha ? Gdk.MemoryFormat.R8G8B8A8 :  Gdk.MemoryFormat.R8G8B8, bytes, rowstride);
    }
    // else result.icon = new ThemedIcon("missing-image");

    result.activate_fun = (owned)activate;

    return result;
  }

  internal static SearchResult from_app_data(AstalApps.Application app, owned ActivateResult activate) {
    var result = new SearchResult();

    result.id = app.entry;
    result.name = app.name;
    result.description = app.description;
    if (app.icon_name != null && FileUtils.test(app.icon_name, FileTest.EXISTS)) {
      result.icon = new FileIcon(File.new_for_path(app.icon_name));
    } else {
      result.icon = new ThemedIcon(app.icon_name != null ? app.icon_name : "missing-image");
    }

    result.activate_fun = (owned)activate;

    return result;
  }
}

public interface Kompass.SearchProvider : Object {
  public abstract ListModel results { get; construct; }
  public abstract string name { get; construct; }
  public abstract Icon icon { get; construct; }

  public abstract async void search(string query);

  public virtual bool launch_first() {
    for (int i = 0; i < this.results.get_n_items(); i++) {
      var item = this.results.get_item(i) as SearchResult;
      if (item != null) {
        item.activate();
        return true;
      }
    }
    return false;
  }
}

[DBus(name = "org.gnome.Shell.SearchProvider2")]
internal interface IGnomeSearchProvider : DBusProxy {
  public abstract async string[] get_initial_result_set(string[] terms) throws DBusError, IOError;

  public abstract async string[] get_subsearch_result_set(string[] previous_results, string[] terms) throws DBusError, IOError;

  public abstract async HashTable<string, Variant>[] get_result_metas(string[] ids) throws DBusError, IOError;
  public abstract async void activate_result(string id, string[] terms, uint timestamp) throws DBusError, IOError;
  public abstract async void launch_search(string[] terms, uint timestamp) throws DBusError, IOError;
}

public class Kompass.GnomeSearchProvider : Object, SearchProvider {
  private IGnomeSearchProvider proxy;
  public ListModel results { get; construct; }
  public string name { get; construct; }
  public Icon icon { get; construct; }
  public string path { get; construct; }

  public GnomeSearchProvider(string path) {
    Object(path: path);
  }

  construct {
    this.results = new ListStore(typeof(SearchResult));
    try {
      string dir_path = "gnome-shell/search-providers/";

      KeyFile keyfile = new KeyFile();
      keyfile.load_from_data_dirs(dir_path + this.path, null, KeyFileFlags.NONE);

      string desktop_id = keyfile.get_string("Shell Search Provider", "DesktopId");
      string bus_name = keyfile.get_string("Shell Search Provider", "BusName");
      string object_path = keyfile.get_string("Shell Search Provider", "ObjectPath");
      int version = keyfile.get_integer("Shell Search Provider", "Version");

      string desktop_path = "applications/" + desktop_id;
      KeyFile desktop_keyfile = new KeyFile();
      desktop_keyfile.load_from_data_dirs(desktop_path, null, KeyFileFlags.NONE);
      string name = desktop_keyfile.get_string("Desktop Entry", "Name");
      string icon = desktop_keyfile.get_string("Desktop Entry", "Icon");

      this.name = this.name ?? name;
      this.icon = this.icon ?? new ThemedIcon(icon);

      Bus.get_proxy.begin<IGnomeSearchProvider>(
        BusType.SESSION,
        bus_name,
        object_path,
        0,
        null,
        (obj, res) => {
        try {
          proxy = Bus.get_proxy.end(res);
        }
        catch (Error e) {
          critical("could not create DBusSearchProvider for %s: %s\n", path, e.message);
        }
      });
    }
    catch (Error e) {
      critical("could not create DBusSearchProvider for %s: %s\n", path, e.message);
    }
  }

  public async void search(string query) {
    HashTable<string, Variant>[] result_metas = null;
    try {
      var query_result = yield proxy.get_initial_result_set(query.split(" "));

      if (query_result != null && query_result.length > 0) {
        result_metas = yield proxy.get_result_metas(query_result);
      }
    }
    catch (Error e) {
    }

    (results as ListStore)?.remove_all();
    foreach (var meta in result_metas) {
      var search_result = SearchResult.from_dbus_data(meta, (result) => {
        proxy.activate_result.begin(result.id, query.split(" "), 0);
      });
      (results as ListStore)?.append(search_result);
    }
  }
}

public class Kompass.AppSearchProvider : Object, SearchProvider {
  public ListModel results { get; construct; }
  private AstalApps.Apps apps = new AstalApps.Apps();
  public string name { get; construct; }
  public Icon icon { get; construct; }

  construct {
    name = this.name ?? "Apps";
    icon = this.icon ?? new FileIcon(File.new_for_uri("resource://com/github/kotontrion/libkompass/icons/symbolic/ui/tux-symbolic.svg"));
    results = new ListStore(typeof(SearchResult));
    this.search.begin("");
  }

  public async void search(string query) {
    var result = apps.fuzzy_query(query);
    (results as ListStore)?.remove_all();
    foreach (var app in result) {
      var search_result = SearchResult.from_app_data(app, (result) => {
        app.launch();
      });
      (results as ListStore)?.append(search_result);
    }
  }
}
