[GtkTemplate(ui = "/com/github/kotontrion/libkompass/ui/wifi-ap.ui")]
public class Kompass.WifiAp : Gtk.ListBoxRow {
  public AstalNetwork.Network network { get; set; }
  public AstalNetwork.Wifi wifi { get; set; }
  public AstalNetwork.AccessPoint ap { get; set; }

  private SimpleActionGroup actions;

  public bool active { get; set; }
  public string description { get; private set; }

  [GtkChild]
  public unowned Gtk.PopoverMenu context_menu;

  [GtkCallback]
  public void clicked() {
    if (this.active) {
      this.wifi.deactivate_connection.begin();
    } else if (this.ap.get_connections().length > 0) {
      this.ap.activate.begin(null);
    } else {
      open_wifi_dialog(null);
    }
  }

  [GtkCallback]
  public void open_menu() {
    context_menu.popup();
  }

  private void open_wifi_dialog(NM.Connection? connection) {
    NM.Connection con;
    if (connection == null) {
      con = NM.SimpleConnection.new();

      con.add_setting(new NM.SettingWireless() {
        ssid = this.ap.ap.ssid
      });
      con.add_setting(new NM.SettingConnection() {
        uuid = NM.Utils.uuid_generate()
      });
    } else {
      con = connection;
    }

    var dialog = new NMA.WifiDialog(this.network.client, con, null, this.ap.ap, false) {
      deletable = false,
      modal = true,
      transient_for = (Gtk.Window)this.get_root()
    };
    dialog.present();

    dialog.response.connect((response) => {
      if (response == Gtk.ResponseType.OK) {
        NM.Device dialog_device;
        NM.AccessPoint dialog_ap;
        var dialog_connection = dialog.get_connection(out dialog_device, out dialog_ap);
        if (connection == null) {
          this.network.client.add_and_activate_connection_async.begin(dialog_connection, dialog_device, dialog_ap.get_path(), null);
        } else {
          connection.replace_settings_from_connection(dialog_connection);
          (connection as NM.RemoteConnection).commit_changes(true, null);
        }
      }
      dialog.destroy();
    });
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

    this.actions = new GLib.SimpleActionGroup();

    Signal.connect_object(wifi, "notify::active-access-point", (Callback)check_active, this, ConnectFlags.SWAPPED);
    this.check_active();

    var con_action = new SimpleAction.stateful("connected", null, new Variant.boolean(this.active));
    con_action.change_state.connect(val => {
      this.clicked();
    });
    this.bind_property("active", con_action, "state",
                       BindingFlags.DEFAULT, (binding, srcval, ref targetval) => {
      bool src = (bool)srcval;
      targetval.set_variant(new Variant("b", src));
      return true;
    });
    this.actions.add_action(con_action);

    var rem_action = new SimpleAction("forget", null);
    rem_action.activate.connect(val => {
      this.ap.get_connections().foreach(con => {
        con.delete_async.begin(null);
      });
    });
    this.actions.add_action(rem_action);

    var edit_action = new SimpleAction("edit", null);
    edit_action.activate.connect(val => {
      if (this.ap.get_connections().length > 0) {
        this.open_wifi_dialog(this.ap.get_connections().get(0));
      } else {
        this.open_wifi_dialog(null);
      }
    });
    this.actions.add_action(edit_action);

    this.insert_action_group("wifi-ap", this.actions);
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
