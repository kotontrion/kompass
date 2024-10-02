[GtkTemplate (ui = "/com/github/kotontrion/kompass/ui/qs.ui")]
public class Kompass.Qs : Gtk.Box {

    public AstalWp.Wp wp {get; private set;}
    public AstalBattery.Device battery {get; private set;}
    public AstalNetwork.Network network {get; private set;}
    public AstalBluetooth.Bluetooth bluetooth {get; private set;}

    [GtkChild]
    private unowned Gtk.Popover popover;

    [GtkChild]
    private unowned Adw.NavigationView nav_view;


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

    [GtkCallback]
    public void push_stack_audio() {
        nav_view.push_by_tag("audio");
    }

    [GtkCallback]
    public void push_stack_bt() {
        nav_view.push_by_tag("bluetooth");
    }

    [GtkCallback]
    public bool on_scroll(Gtk.EventControllerScroll scroll, double dx, double dy) {
        double delta = dy > 0 ? -0.03 : 0.03;
        this.wp.audio.default_speaker.volume += delta;
        return true;
    }

    construct {
        this.wp = AstalWp.get_default();
        this.battery = AstalBattery.get_default();
        this.network = AstalNetwork.get_default();
        this.bluetooth = AstalBluetooth.get_default();
    }

}
