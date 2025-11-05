[GtkTemplate(ui = "/com/github/kotontrion/libkompass/ui/wifi-ap.ui")]
public class Kompass.WifiAp : Gtk.ListBoxRow {
  public AstalNetwork.Network network { get; set; }
  public AstalNetwork.Wifi wifi { get; set; }
  public AstalNetwork.AccessPoint ap { get; set; }

  public bool active { get; set; }
  public string description { get; private set; }

  [GtkCallback]
  public void clicked() {
    if (this.active) {
      this.wifi.deactivate_connection.begin();
    } else if (this.ap.get_connections().length > 0) {
      this.ap.activate.begin(null);
    } else {
      var connection = NM.SimpleConnection.new();

      connection.add_setting(new NM.SettingWireless() {
        ssid = this.ap.ap.ssid
      });
      connection.add_setting(new NM.SettingConnection() {
        uuid = NM.Utils.uuid_generate()
      });
      var dialog = new NMA.WifiDialog(this.network.client, connection, null, this.ap.ap, false);
      dialog.present();

      dialog.response.connect((response) => {
        if (response == Gtk.ResponseType.OK) {
          NM.Device dialog_device;
          NM.AccessPoint dialog_ap;
          var dialog_connection = dialog.get_connection(out dialog_device, out dialog_ap);
          this.network.client.add_and_activate_connection_async.begin(dialog_connection, dialog_device, dialog_ap.get_path(), null);
        }
        dialog.destroy();
      });
    }
  }

  private void check_active() {
    this.active = wifi.active_access_point?.bssid == this.ap.bssid;

    this.description = this.active
                       ? "connected"
                       : this.ap.get_connections().length > 0
                       ? "saved"
                       : this.ap.requires_password
                       ? "protected"
                       : "open";
  }

  public WifiAp(AstalNetwork.Network network, AstalNetwork.Wifi wifi, AstalNetwork.AccessPoint ap) {
    Object(ap: ap, wifi: wifi, network: network);
    Signal.connect_object(wifi, "notify::active-access-point", (Callback)check_active, this, ConnectFlags.SWAPPED);
    this.check_active();
  }

  public int compare_to(Kompass.WifiAp other) {
    if (this.active != other.active) {
      return (int)other.active - (int)this.active;
    }

    if (this.ap.strength != other.ap.strength) {
      return other.ap.strength - this.ap.strength;
    }

    return strcmp(other.ap.ssid, this.ap.ssid);
  }
}
