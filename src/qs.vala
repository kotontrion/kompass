[GtkTemplate (ui = "/com/github/kotontrion/kompass/ui/qs.ui")]
public class Kompass.Qs : Gtk.Box {

    public AstalWp.Wp wp {get; private set;}
    public AstalBattery.Device battery {get; private set;}
    public AstalNetwork.Network network {get; private set;}
    public AstalBluetooth.Bluetooth bluetooth {get; private set;}

    private int count = 0;

    [GtkChild]
    private unowned Gtk.Popover popover;

    [GtkChild]
    private unowned Adw.NavigationView nav_view;

    [GtkChild]
    private unowned Gtk.Revealer rev_volume;

    [GtkCallback]
    public string bluetooth_icon_name(bool connected) {
        return connected
            ? "bluetooth-active-symbolic"
            : "bluetooth-disabled-symbolic";
    }

    [GtkCallback]
    public void popup() {
        nav_view.pop_to_tag("dashboard");
        popover.popup();
    }

    [GtkCallback]
    public void on_bt_clicked() {
        this.bluetooth.adapter.powered = !this.bluetooth.adapter.powered;
    }

    [GtkCallback]
    public void on_bt_arrow_clicked() {
        nav_view.push_by_tag("bluetooth");
    }

    [GtkCallback]
    public void on_audio_clicked() {
        this.wp.audio.default_speaker.mute = !this.wp.audio.default_speaker.mute;
    }

    [GtkCallback]
    public void on_audio_arrow_clicked() {
        nav_view.push_by_tag("audio");
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

        this.wp.audio.default_speaker.notify["volume"].connect(() => {
            this.count++;
            rev_volume.reveal_child = true;
            GLib.Timeout.add(2000, () => {
                if(--this.count == 0)
                    rev_volume.reveal_child = false;
                return GLib.Source.REMOVE;
            });
        });
    }

}
