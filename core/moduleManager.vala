
namespace Kompass {

public errordomain ModuleError {
	NOT_SUPPORTED,
	FAILED,
  NO_FUNCTION,
  TYPE_NOT_REGISTERED
}

public delegate void InitModule();
public delegate Type GTypeGetFunc();

public class Module {
  public string name;
  public unowned GLib.Module module;
  public InitModule init;

  public Module(string name) throws ModuleError {


    if (GLib.Module.supported () == false) {
		  throw new ModuleError.NOT_SUPPORTED ("Plugins are not supported");
	  }

    string module_dir = GLib.Environment.get_user_config_dir();
    GLib.Module module = null;
    int i = 0;
    string[] module_search_paths = GLib.Environment.get_system_data_dirs();

    do {
      module = GLib.Module.open (module_dir + "/kompass/modules/" + name + "/libmodule.so", ModuleFlags.LAZY);
      if (module != null) {
        break;
      }
      module_dir = module_search_paths[i++];
    } while (i <= module_search_paths.length);
    
    if (module == null) {
      throw new ModuleError.FAILED("no module %s not found", name);
    }

    this.module = module;

    void* init_function;
    module.symbol ("init", out init_function);
    if (init_function == null) {
      throw new ModuleError.NO_FUNCTION("no init function found in module %s", name);
    }

    this.init = (InitModule) init_function;
    this.init();
    
    module.make_resident();
   

  }
}

public class ModuleManager {

  private GLib.HashTable<string, Kompass.Module> modules;
  
  public ModuleManager() {

    this.modules = new GLib.HashTable<string, Kompass.Module>(GLib.str_hash, GLib.str_equal);

  }

  public void load_module(string name) throws ModuleError {
    if (this.modules.contains(name)) return;
    Kompass.Module module = new Kompass.Module(name);
    this.modules.insert(name, module);
  }

  public Type ensure_type(string type) throws Kompass.ModuleError {
    string type_name = type.replace(".", "");
    Type gtype = GLib.Type.from_name(type_name);
    if (gtype == Type.INVALID) {
      gtype = get_type_from_name(type_name);
    }
    if (gtype == Type.INVALID) {
      this.load_module(type.split(".", 0)[0]);
      gtype = get_type_from_name(type_name);
    }
    if (gtype == Type.INVALID) {
      throw new Kompass.ModuleError.TYPE_NOT_REGISTERED("the type %s could not be found", type);
    }
    return gtype;
  }

  private string guess_get_type_name (string name) {
    string symbol_name = "";
    int i;
    for (i = 0; name[i] != '\0'; i++) {
      if ((name[i] == name[i].toupper() &&
           i > 0 && name[i-1] != name[i-1].toupper()) ||
           (i > 2 && name[i] == name[i].toupper() &&
           name[i-1] == name[i-1].toupper() &&
           name[i-2] == name[i-2].toupper()))
        symbol_name += "_";
      symbol_name += name[i].tolower().to_string();
    }
    symbol_name += "_get_type";
    return symbol_name;
  }

  private Type get_type_from_name (string name) {
    void* func;
    Type gtype = Type.INVALID;
    GLib.Module module = GLib.Module.open(null, 0);
    string symbol = guess_get_type_name(name);
    if (module.symbol(symbol, out func))
      gtype = ((GTypeGetFunc)func)();

    return gtype;
  }

}
}
