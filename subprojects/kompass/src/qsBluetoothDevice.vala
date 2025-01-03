[GtkTemplate(ui = "/com/github/kotontrion/kompass-bar/ui/qsBluetoothDevice.ui")]
public class KompassBar.QsBluetoothDevice : Gtk.ListBoxRow {
  public AstalBluetooth.Device device { get; construct set; }
  private SimpleActionGroup actions;

  [GtkChild]
  public unowned Gtk.PopoverMenu context_menu;

  [GtkCallback]
  public string icon_substitue(string? icon) {
    if (icon == null) {
      return "bluetooth-active";
    }
    return icon;
  }

  [GtkCallback]
  public void open_menu() {
    context_menu.popup();
  }

  [GtkCallback]
  public void toggle_connection() {
    if (this.device.connected) {
      this.device.disconnect_device.begin();
    } else {
      this.device.connect_device.begin();
    }
  }

  public QsBluetoothDevice(AstalBluetooth.Device device) {
    Object(device: device);

    this.actions = new GLib.SimpleActionGroup();

    var con_action = new SimpleAction.stateful("connected", null, new Variant.boolean(device.connected));
    con_action.change_state.connect(val => {
      this.toggle_connection();
    });
    this.device.bind_property("connected", con_action, "state",
                              BindingFlags.DEFAULT, (binding, srcval, ref targetval) => {
      bool src = (bool)srcval;
      targetval.set_variant(new Variant("b", src));
      return true;
    });
    this.actions.add_action(con_action);

    var rem_action = new SimpleAction("remove", null);
    rem_action.activate.connect(val => {
      AstalBluetooth.get_default().adapter.remove_device(this.device);
    });
    this.actions.add_action(rem_action);

    this.actions.add_action(
      new PropertyAction("trusted", this.device, "trusted"));
    this.actions.add_action(
      new PropertyAction("blocked", this.device, "blocked"));

    this.insert_action_group("bl-dev", this.actions);
  }
}
