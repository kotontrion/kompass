[GtkTemplate(ui = "/net/kotontrion/libkompass/ui/bluetooth-device.ui")]
public class Kompass.BluetoothDevice : Gtk.ListBoxRow {
  public AstalBluetooth.Device device { get; construct; }
  private SimpleActionGroup actions;

  [GtkChild]
  public unowned Gtk.PopoverMenu context_menu;

  [GtkChild]
  public unowned Gtk.Svg svg;

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

  private void update_svg_state() {
    if (this.device.connected) {
      this.svg.set_state(2);
    } else if (this.device.connecting) {
      this.svg.set_state(1);
    } else {
      this.svg.set_state(0);
    }
  }

  public BluetoothDevice(AstalBluetooth.Device device) {
    Object(device: device);
  }

  construct {
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
      try {
        AstalBluetooth.get_default().adapter.remove_device(this.device);
      }
      catch (Error e) {
        warning("could not remove bluetooth device: %s\n", e.message);
      }
    });
    this.actions.add_action(rem_action);

    this.actions.add_action(
      new PropertyAction("trusted", this.device, "trusted"));
    this.actions.add_action(
      new PropertyAction("blocked", this.device, "blocked"));

    this.insert_action_group("bl-dev", this.actions);

    this.device.notify.connect(() => {
      update_svg_state();
    });

    this.realize.connect(() => {
      this.svg.set_frame_clock(this.get_frame_clock());
      update_svg_state();
    });
  }
}
