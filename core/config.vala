

public errordomain ConfigError {
	UNEXPECTED_TYPE,
	FAILED
}

public static void process_properties(Json.Node node, out string[] names, out Value[] values, Kompass.ModuleManager manager) throws Kompass.ModuleError {
  unowned Json.Object obj = node.get_object ();
  names = new string[obj.get_size()];
  values = new Value[obj.get_size()];
  int i = 0;
  foreach (unowned string name in obj.get_members ()) {
    names[i] = name;
    Json.Node prop = obj.get_member(name);
    if(prop.get_node_type() == Json.NodeType.OBJECT) {
      Json.Object prop_obj = prop.get_object();
      if(prop_obj.has_member("type")) {
        Value val_obj = Value(typeof(Object));
        val_obj.set_object(process_module(prop, manager));
        values[i] = val_obj;
        i++;
        continue;
      }
    }
    values[i] = prop.get_value();
    i++;
  }
}


public static Object process_module(Json.Node node, Kompass.ModuleManager manager) throws Kompass.ModuleError {
  unowned Json.Object obj = node.get_object ();

  string type = obj.get_string_member ("type");
  Type gtype = Type.INVALID;
  try {
    gtype = manager.ensure_type(type);
  }
  catch (Kompass.ModuleError e) {
    critical("%s", e.message);
  }

 
  string[] prop_names;
  Value[] prop_values;
  process_properties(obj.get_member("properties"), out prop_names, out prop_values, manager);
  return Object.new_with_properties (gtype, prop_names, prop_values);

}



public static void process (Json.Node node, Kompass.ModuleManager manager) throws Kompass.ModuleError {

  unowned Json.Array array = node.get_array ();

	foreach (unowned Json.Node item in array.get_elements ()) {
		process_module (item, manager);
	}

}


