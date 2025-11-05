[GtkTemplate(ui = "/com/github/kotontrion/kompass-bar/ui/qs.ui")]
public class KompassBar.Qs : Gtk.Box {
  public AstalWp.Wp wp { get; private set; }
  public AstalBattery.Device battery { get; private set; }
  public AstalNetwork.Network network { get; private set; }
  public AstalBluetooth.Bluetooth bluetooth { get; private set; }
  public AstalNotifd.Notifd notifd { get; private set; }
  public AstalMpris.Mpris mpris { get; private set; }

  private SimpleActionGroup actions;
  private int count = 0;

  public Kompass.ScreenRecorder recorder { get; set; default = Kompass.ScreenRecorder.get_default(); }

  [GtkChild]
  private unowned Gtk.Popover popover;

  [GtkChild]
  private unowned Adw.NavigationView nav_view;

  [GtkChild]
  private unowned Gtk.Revealer rev_volume;

  [GtkChild]
  private unowned Adw.Carousel players;

  [GtkCallback]
  public string battery_label(double percentage) {
    return "%.0f%%".printf(percentage * 100);
  }

  [GtkCallback]
  public string recorder_icon(bool recording) {
    return recording ? "media-record-symbolic" : "video-display-symbolic";
  }

  [GtkCallback]
  public void open_settings() {
    Process.spawn_async("/",
                        { "bash", "-c", "XDG_CURRENT_DESKTOP=gnome gnome-control-center" },
                        null,
                        SpawnFlags.SEARCH_PATH,
                        null,
                        null);
  }

  [GtkCallback]
  public void record_right_click() {
    if (recorder.recording) {
      stop_record();
    } else {
      start_record();
    }
  }

  [GtkCallback]
  public void record_click() {
    if (recorder.recording) {
      stop_record();
    } else {
      screenshot();
    }
  }

  private void stop_record() {
    recorder.stop_record();
  }

  private void start_record() {
    recorder.start_record(null);
  }

  private void screenshot() {
    recorder.take_screenshot.begin(null);
  }

  [GtkCallback]
  public string bluetooth_icon_name(bool connected) {
    return connected
           ? "bluetooth-active-symbolic"
           : "bluetooth-disabled-symbolic";
  }

  [GtkCallback]
  public bool notification_icon_visible(List notifications) {
    return notifications.length() > 0;
  }

  [GtkCallback]
  public string notification_dnd_icon(bool dnd) {
    return dnd
           ? "notifications-disabled-symbolic"
           : "user-available-symbolic";
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
  public void on_notif_clicked() {
    this.notifd.dont_disturb = !this.notifd.dont_disturb;
  }

  [GtkCallback]
  public void on_notif_arrow_clicked() {
    nav_view.push_by_tag("notifications");
  }

  [GtkCallback]
  public void on_wifi_clicked() {
    this.network.wifi.enabled = !this.network.wifi.enabled;
  }

  [GtkCallback]
  public void on_wifi_arrow_clicked() {
    //nav_view.push_by_tag("wifi");
  }

  [GtkCallback]
  public bool on_scroll(Gtk.EventControllerScroll scroll, double dx, double dy) {
    double delta = dy > 0 ? -0.03 : 0.03;

    this.wp.audio.default_speaker.volume += delta;
    return true;
  }

  private void on_player_added(AstalMpris.Player player) {
    this.players.append(new Kompass.Player(player));
  }

  private void on_player_removed(AstalMpris.Player player) {
    for (int i = 0; i < this.players.n_pages; i++) {
      Kompass.Player p = (Kompass.Player)this.players.get_nth_page(i);
      if (p.player == player) {
        this.players.remove(p);
      }
    }
  }

  construct {
    this.wp = AstalWp.get_default();
    this.battery = AstalBattery.get_default();
    this.network = AstalNetwork.get_default();
    this.bluetooth = AstalBluetooth.get_default();
    this.notifd = AstalNotifd.get_default();
    this.mpris = AstalMpris.get_default();

    this.wp.audio.default_speaker.notify["volume"].connect(() => {
      this.count++;
      rev_volume.reveal_child = true;
      GLib.Timeout.add(2000, () => {
        if (--this.count == 0) {
          rev_volume.reveal_child = false;
        }
        return GLib.Source.REMOVE;
      });
    });

    this.mpris.players.@foreach((p) => this.on_player_added(p));
    this.mpris.player_added.connect((p) => this.on_player_added(p));
    this.mpris.player_closed.connect((p) => this.on_player_removed(p));

    this.actions = new GLib.SimpleActionGroup();

    var sd_action = new SimpleAction("shutdown", null);
    sd_action.activate.connect(val => {
      Process.spawn_async("/",
                          { "systemctl", "poweroff" },
                          null,
                          SpawnFlags.SEARCH_PATH,
                          null,
                          null);
    });
    this.actions.add_action(sd_action);

    var rb_action = new SimpleAction("reboot", null);
    rb_action.activate.connect(val => {
      Process.spawn_async("/",
                          { "systemctl", "reboot" },
                          null,
                          SpawnFlags.SEARCH_PATH,
                          null,
                          null);
    });
    this.actions.add_action(rb_action);

    var suspend_action = new SimpleAction("suspend", null);
    suspend_action.activate.connect(val => {
      Process.spawn_async("/",
                          { "systemctl", "suspend" },
                          null,
                          SpawnFlags.SEARCH_PATH,
                          null,
                          null);
    });
    this.actions.add_action(suspend_action);

    var logout_action = new SimpleAction("logout", null);
    logout_action.activate.connect(val => {
      Process.spawn_async("/",
                          { "bash", "-c", "loginctl terminate-user $USER" },
                          null,
                          SpawnFlags.SEARCH_PATH,
                          null,
                          null);
    });
    this.actions.add_action(logout_action);

    var lock_action = new SimpleAction("lock", null);
    lock_action.activate.connect(val => {
      print("lock is not implemented yet\n");
    });
    this.actions.add_action(lock_action);

    this.insert_action_group("pm", this.actions);
  }
}
