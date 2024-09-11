public struct WindowConfig {
  string monitor;
  Json.Object window;
}

public struct Config {
  string style;
  WindowConfig[] windows;
}



public errordomain ConfigError {
	UNEXPECTED_TYPE,
	FAILED
}

private static List* map_values (List<Value?> values) {
  if (values.length() == 0) {
    return values;
  }

  Type type = Type.NONE;

  foreach (Value? val in values) {
    if (val != null) {
        type = val.type();
        break;
    }
  }

  if (type == Type.NONE) {
    return values;
  }

  foreach (Value? val in values) {
    if (val != null && val.type() != type) {
        return values;
    }
  }

  return cast_list(values, type);
}

delegate T AccessFunc<T>(Value? val);

private static List* cast_list(List<Value?> values, Type type) {
  switch (type) {
    case Type.OBJECT:
    return cast_values_to_list<Object>(values, (val) => val.get_object());
    case Type.STRING:
    return cast_values_to_list<string>(values, (val) => val.get_string());
    case Type.DOUBLE:
    return cast_values_to_list<double?>(values, (val) => val.get_double());
    case Type.BOOLEAN:
    return cast_values_to_list<bool>(values, (val) => val.get_boolean());
    case Type.INT64:
    return cast_values_to_list<int64?>(values, (val) => val.get_int64());
    default:
    return values;
  }
}

private static List<T>* cast_values_to_list<T> (List<Value?> values, AccessFunc<T> get) {
  List<T> *result = new List<T>();
  foreach (Value? val in values) {
      result->append(get(val));
  }
  return result;
}

private static Value? get_property_value(string name, Json.Node node, Kompass.ModuleManager manager) throws Kompass.ModuleError {
  switch (node.get_node_type()) {
    case Json.NodeType.OBJECT:
      unowned Json.Object prop_obj = node.get_object();
      if(prop_obj.has_member("type")) {
        Value val_obj = Value(typeof(Object));
        Object o = process_module(node.get_object(), manager);
        o.ref();
        val_obj.set_object(o);
        return val_obj;
      }
      else return node.get_value();
    case Json.NodeType.ARRAY:
      Value val_array = Value(typeof(List));
      unowned Json.Array array = node.get_array();
      List<Value?> *items = new List<Value?>();
      array.foreach_element((a, i, p) => {
        items->append(get_property_value(name, p, manager));
      });
      val_array.set_pointer(map_values(items));
      return val_array;
    default:
      return node.get_value();
  }

}

private static void process_properties(Json.Node node, out string[] out_names, out Value[] out_values, Kompass.ModuleManager manager) throws Kompass.ModuleError {
  unowned Json.Object obj = node.get_object ();
  string[] names = {};
  Value[] values = {};
  int i = 0;
  foreach (unowned string name in obj.get_members ()) {
    unowned Json.Node prop = obj.get_member(name);
    Value? prop_value = get_property_value(name, prop, manager);
    if(prop_value == null) continue;
    names += name;
    values += prop_value;
    i++;
  }
  out_names = names;
  out_values = values;
}


private static Object process_module(Json.Object obj, Kompass.ModuleManager manager) throws Kompass.ModuleError {
  string type = obj.get_string_member ("type");
  Type gtype = Type.INVALID;
  try {
    gtype = manager.ensure_type(type);
  }
  catch (Kompass.ModuleError e) {
    critical("%s", e.message);
  }

  string[] prop_names = null;
  Value[] prop_values = null;
  if(obj.has_member("properties")) { 
    process_properties(obj.get_member("properties"), out prop_names, out prop_values, manager);
  }

  

  Object module = Object.new_with_properties (gtype, prop_names, prop_values);
 
  int index = -1;
  for (int i = 0; i < prop_names.length; i++) {
      if (prop_names[i] == "visible") {
          index = i;
          break;
      }
  }

  if(index == -1 || prop_values[index] == true) {
    ((Gtk.Widget) module).show();
  }

  return module;
}


public static Gtk.Window load_window(Json.Object node, Kompass.ModuleManager manager) throws ModuleError {
	return (Gtk.Window)process_module (node, manager);
}


public static Config load_config (Json.Node node, Astal.Application app, Kompass.ModuleManager manager) throws Kompass.ModuleError {

  Config config = {};
  unowned Json.Object conf = node.get_object();
  if(conf.has_member("style")) {
    config.style = conf.get_string_member("style");
  }
 
  if(conf.has_member("windows")) {
    WindowConfig[] wins = {};
    conf.get_array_member("windows").foreach_element((windows, index, win) => {
      WindowConfig win_conf = {};
      win_conf.window = win.get_object();
      if(win.get_object().has_member("monitor")) {
        win_conf.monitor = win.get_object().get_string_member("monitor");
      }
      wins += win_conf;
    });
    config.windows = wins;
  }

  return config;
}


