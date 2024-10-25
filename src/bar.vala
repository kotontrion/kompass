using GtkLayerShell;

[GtkTemplate (ui = "/com/github/kotontrion/kompass/ui/bar.ui")]
public class Kompass.Bar : Gtk.Window {

    public AstalRiver.Output output { get; private set; }

    public Bar (Gtk.Application app, AstalRiver.Output output) {
        Object (application: app, css_name: "bar");
        this.output = output;
        this.name = @"bar-$(output.name)";
        
        init_for_window(this);
        set_namespace(this, @"bar-$(output.name)");
        set_anchor(this, Edge.TOP, true);
        set_anchor(this, Edge.LEFT, true);
        set_anchor(this, Edge.BOTTOM, true);
        set_margin(this, Edge.TOP, 4);
        set_margin(this, Edge.LEFT, 4);
        set_margin(this, Edge.BOTTOM, 4);
        auto_exclusive_zone_enable(this);

        set_keyboard_mode(this, GtkLayerShell.KeyboardMode.ON_DEMAND);

        ListModel monitors = Gdk.Display.get_default().get_monitors();
        for(int i = 0; i < monitors.get_n_items(); i++) {
            Gdk.Monitor monitor = (Gdk.Monitor)monitors.get_item(i);
            if(monitor.connector == output.name) {
                set_monitor(this, monitor);
                break;
            }
        }
    }
}
