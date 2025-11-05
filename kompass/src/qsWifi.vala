[GtkTemplate(ui = "/com/github/kotontrion/kompass-bar/ui/qsWifi.ui")]
public class KompassBar.QsWifi : Gtk.Box {
  public AstalNetwork.Network network { get; construct set; }

  private SignalGroup wifi_group;

  [GtkChild]
  private unowned Gtk.ListBox aps;

  private void on_added(AstalNetwork.AccessPoint ap) {
    if (ap.ssid == null || ap.ssid == "") {
      return;
    }
    this.aps.append(new Kompass.WifiAp(this.network, this.network.wifi, ap));
    this.aps.invalidate_sort();
  }

  private void on_removed(AstalNetwork.AccessPoint ap) {
    int i = 0;

    Kompass.WifiAp? ep = (Kompass.WifiAp)this.aps.get_row_at_index(0);
    while (ep != null) {
      if (ep.ap == ap) {
        this.aps.remove(ep);
        break;
      }
      ep = (Kompass.WifiAp)this.aps.get_row_at_index(++i);
    }
    this.aps.invalidate_sort();
  }

  construct {
    this.network = AstalNetwork.get_default();

    this.aps.set_sort_func((a, b) => (a as Kompass.WifiAp).compare_to(b as Kompass.WifiAp));

    this.wifi_group = new SignalGroup(typeof(AstalNetwork.Wifi));
    this.wifi_group.connect_swapped("access-point-added", (Callback)on_added, this);
    this.wifi_group.connect_swapped("access-point-removed", (Callback)on_removed, this);
    this.wifi_group.connect_swapped("notify::active-access-point", (Callback)this.aps.invalidate_sort, this.aps);

    this.wifi_group.set_target(this.network.wifi);

    if (this.network.wifi != null) {
      this.network.wifi.access_points.@foreach(ap => this.on_added(ap));
    }
//    this.wp.audio.stream_added.connect((audio, endpoint) => this.on_added(endpoint, this.mixers));
//    this.wp.audio.stream_removed.connect((audio, endpoint) => this.on_removed(endpoint, this.mixers));
  }
}
