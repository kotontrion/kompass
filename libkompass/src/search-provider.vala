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
    if (icon != null) {
      result.icon = Icon.deserialize(icon);
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
    if (app.icon_name != null && FileUtils.test(app.icon_name, FileTest.EXISTS))
      result.icon = new FileIcon(File.new_for_path(app.icon_name));
    else
      result.icon = new ThemedIcon(app.icon_name != null ? app.icon_name : "missing-image");

    result.activate_fun = (owned)activate;

    return result;
  }
}

public interface Kompass.SearchProvider : Object {
  public abstract ListModel results { get; construct; }
  public abstract string name { get; construct; }
  public abstract Icon icon { get; construct; }

  public abstract async void search(string query);
}

[DBus(name = "org.gnome.Shell.SearchProvider2")]
internal interface IDBusSearchProvider : DBusProxy {
  public abstract async string[] get_initial_result_set(string[] terms) throws DBusError, IOError;

  public abstract async string[] get_subsearch_result_set(string[] previous_results, string[] terms) throws DBusError, IOError;

  public abstract async HashTable<string, Variant>[] get_result_metas(string[] ids) throws DBusError, IOError;
  public abstract async void activate_result(string id, string[] terms, uint timestamp) throws DBusError, IOError;
  public abstract async void launch_search(string[] terms, uint timestamp) throws DBusError, IOError;
}

public class Kompass.DBusSearchProvider : Object, SearchProvider {
  private IDBusSearchProvider proxy;
  public ListModel results { get; construct; }
  public string name { get; construct; }
  public Icon icon { get; construct; }

  public async DBusSearchProvider(string desktop_id, string bus_name, string path) {
    string desktop_path = "applications/" + desktop_id;

    KeyFile keyfile = new KeyFile();
    keyfile.load_from_data_dirs(desktop_path, null, KeyFileFlags.NONE);
    string name = keyfile.get_string("Desktop Entry", "Name");
    string icon = keyfile.get_string("Desktop Entry", "Icon");

    Object(name: name,
           icon: new ThemedIcon(icon),
           results: new ListStore(typeof(SearchResult))
           );

    proxy = yield Bus.get_proxy(
      BusType.SESSION,
      bus_name,
      path
      );
  }

  public async void search(string query) {
    string [] s = query.split(" ");
    HashTable<string, Variant>[] result_metas = null;
    try {
      var query_result = yield proxy.get_initial_result_set(query.split(" "));

      if (query_result != null && query_result.length > 0) {
        result_metas = yield proxy.get_result_metas(query_result);
      }
    }
    catch (Error e) {
    }

    (results as ListStore).remove_all();
    foreach (var meta in result_metas) {
      var search_result = SearchResult.from_dbus_data(meta, (result) => {
        proxy.activate_result(result.id, query.split(" "), 0);
      });
      (results as ListStore).append(search_result);
    }
  }
}

public class Kompass.AppSearchProvider : Object, SearchProvider {
  public ListModel results { get; construct; }
  private AstalApps.Apps apps = new AstalApps.Apps();
  public string name { get; construct; }
  public Icon icon { get; construct; }

  public AppSearchProvider() {
    Object(name: "Apps",
           icon: new ThemedIcon("arch-linux"),
           results: new ListStore(typeof(SearchResult)));
  }

  public async void search(string query) {
    var result = apps.fuzzy_query(query);
    (results as ListStore).remove_all();
    foreach (var app in result) {
      var search_result = SearchResult.from_app_data(app, (result) => {
        app.launch();
      });
      (results as ListStore).append(search_result);
    }
  }
}
