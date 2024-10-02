[GtkTemplate (ui = "/com/github/kotontrion/kompass/ui/qsBluetoothDevice.ui")]
public class Kompass.QsBluetoothDevice : Gtk.ListBoxRow {

    public AstalBluetooth.Device device {get; private set;}

    [GtkCallback]
    public string icon_substitue(string? icon) {
      if(icon == null) return "bluetooth-active";
      return icon;
    }


    [GtkCallback]
    public void toggle_connection() {
        if(this.device.connected)
          this.device.disconnect_device.begin();
        else
          this.device.connect_device.begin();
    }

    public QsBluetoothDevice(AstalBluetooth.Device device) {
        Object();
        this.device = device;
    }

}
