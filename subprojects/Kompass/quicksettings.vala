namespace Kompass {

class QSBar : Astal.Box {

  private Astal.Icon battery_icon;
  private Astal.Icon bluetooth_icon;
  private Astal.Icon wifi_icon;

  construct {
    
    Astal.widget_set_class_names(this, {"qs-bar"});

    if(Kompass.battery != null) {
      this.battery_icon = new Astal.Icon();
      Kompass.battery.bind_property(
        "percentage", this.battery_icon, "tooltip_markup", GLib.BindingFlags.SYNC_CREATE,
        (b, f, ref t) => {
          int p = (int)(f.get_double() * 100);
          t.set_string(@"$p%");
          return true;
        });
      Kompass.battery.bind_property("icon-name", this.battery_icon, "icon", GLib.BindingFlags.SYNC_CREATE);
      this.battery_icon.halign = Gtk.Align.CENTER;
      this.battery_icon.valign = Gtk.Align.CENTER;
      this.add(this.battery_icon);
    }

    this.bluetooth_icon = new Astal.Icon();
    this.bluetooth_icon.halign = Gtk.Align.CENTER;
    this.bluetooth_icon.valign = Gtk.Align.CENTER;

    Kompass.bluetooth.bind_property(
      "is_connected", this.bluetooth_icon, "icon", GLib.BindingFlags.SYNC_CREATE,
      (b, f, ref t) => {
        t.set_string(f.get_boolean()
          ? "bluetooth-active-symbolic"
          : "bluetooth-disabled-symbolic"
        );
        return true;
      });
    this.add(this.bluetooth_icon);

    this.wifi_icon = new Astal.Icon();
    this.wifi_icon.halign = Gtk.Align.CENTER;
    this.wifi_icon.valign = Gtk.Align.CENTER; 
    Kompass.network.wifi.bind_property("icon-name", this.wifi_icon, "icon", GLib.BindingFlags.SYNC_CREATE);
    this.add(this.wifi_icon);

    this.show_all();

  }

  public QSBar(bool vertical, List<weak Gtk.Widget> children) {
    base(vertical, children);
  }


}

}
