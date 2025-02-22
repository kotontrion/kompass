[GtkTemplate(ui = "/com/github/kotontrion/kompass-bar/ui/qsBluetooth.ui")]
public class KompassBar.QsBluetooth : Gtk.Box {
  public AstalBluetooth.Bluetooth bluetooth { get; construct set; }

  [GtkChild]
  private unowned Gtk.ListBox devices;

  [GtkChild]
  private unowned Gtk.Switch enable_switch;

  [GtkChild]
  private unowned Gtk.Button scan_button;

  [GtkCallback]
  public void toggle_discover() {
    if (this.bluetooth.adapter.discovering) {
      this.bluetooth.adapter.stop_discovery();
    } else {
      this.bluetooth.adapter.start_discovery();
    }
  }

  [GtkCallback]
  public void toggle_powered() {
    this.bluetooth.adapter.powered = this.enable_switch.active;
  }

  private void on_added(AstalBluetooth.Device device, Gtk.ListBox lb) {
    lb.append(new Kompass.BluetoothDevice(device));
  }

  private void on_removed(AstalBluetooth.Device device, Gtk.ListBox lb) {
    int i = 0;

    Kompass.BluetoothDevice? dev = (Kompass.BluetoothDevice)lb.get_row_at_index(0);
    while (dev != null) {
      if (dev.device == device) {
        lb.remove(dev);
        break;
      }
      dev = (Kompass.BluetoothDevice)lb.get_row_at_index(++i);
    }
  }

  construct {
    this.bluetooth = AstalBluetooth.get_default();

    this.bluetooth.adapter.bind_property("powered", enable_switch, "active",
                                         GLib.BindingFlags.BIDIRECTIONAL | GLib.BindingFlags.SYNC_CREATE);

    this.bluetooth.devices.@foreach(dev => this.on_added(dev, this.devices));
    this.bluetooth.device_added.connect((bl, device) => this.on_added(device, this.devices));
    this.bluetooth.device_removed.connect((bl, device) => this.on_removed(device, this.devices));
  }
}
