[GtkTemplate (ui = "/com/github/kotontrion/kompass/ui/qs.ui")]
public class Kompass.Qs : Gtk.Box {

    public AstalWp.Wp wp {get; private set;}
    public AstalBattery.Device battery {get; private set;}
    public AstalNetwork.Network network {get; private set;}
    public AstalBluetooth.Bluetooth bluetooth {get; private set;}

    [GtkChild]
    private unowned Gtk.Popover popover;

    [GtkCallback]
    public string bluetooth_icon_name(bool connected) {
        return connected
            ? "bluetooth-active-symbolic"
            : "bluetooth-disabled-symbolic";
    }

    [GtkCallback]
    public void popup() {
        popover.popup();
    }

    construct {
        this.wp = AstalWp.get_default();
        this.battery = AstalBattery.get_default();
        this.network = AstalNetwork.get_default();
        this.bluetooth = AstalBluetooth.get_default();
    }

}
