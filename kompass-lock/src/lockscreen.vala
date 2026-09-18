namespace KompassLock {
[GtkTemplate(ui = "/net/kotontrion/kompass-lock/ui/lockscreen.ui")]
public class Lockscreen : Gtk.Box {
  private const int SIDEBAR_EDGE_WIDTH = 48;
  private const int SIDEBAR_CLOSE_DELAY = 350;

  private uint clock_interval;
  private uint sidebar_close_timeout = 0;
  private Gtk.EventControllerMotion pointer_motion;

  public KompassLock.Application app { get; private set; }
  public AstalWp.Endpoint speaker { get; private set; }
  public AstalBrightness.Device screen { get; private set; }
  public AstalBattery.Device? battery { get; private set; }

  [GtkChild]
  private unowned Gtk.Label time;
  [GtkChild]
  private unowned Gtk.Label date;
  [GtkChild]
  private unowned Gtk.Label user;
  [GtkChild]
  private unowned Gtk.Entry visible_input;
  [GtkChild]
  private unowned Gtk.PasswordEntry secret_input;
  [GtkChild]
  private unowned Adw.Carousel media_players;
  [GtkChild]
  private unowned Gtk.Box media_panel;
  [GtkChild]
  private unowned Gtk.Revealer sidebar_revealer;
  [GtkChild]
  private unowned Gtk.Adjustment volume_adjust;
  [GtkChild]
  private unowned Gtk.Adjustment brightness_adjust;

  public Lockscreen(KompassLock.Application application) {
    this.app = application;
  }

  [GtkCallback]
  public string battery_label(AstalBattery.Device? device) {
    if (device == null) {
      return _("Battery unavailable");
    }

    return _("Battery: %.0f%%").printf(device.percentage * 100);
  }

  [GtkCallback]
  public bool battery_available(AstalBattery.Device? device) {
    return device != null && device.is_battery;
  }

  [GtkCallback]
  public void set_volume() {
    speaker.volume = volume_adjust.value;
  }

  [GtkCallback]
  public void set_brightness() {
    screen.brightness = (float)brightness_adjust.value;
  }

  private void setup_media_players() {
    var mpris = AstalMpris.get_default();
    mpris.players.@foreach((player) => add_player(player));
    mpris.player_added.connect(add_player);
    mpris.player_closed.connect(remove_player);
  }

  private void show_sidebar() {
    if (sidebar_close_timeout != 0) {
      GLib.Source.remove(sidebar_close_timeout);
      sidebar_close_timeout = 0;
    }

    sidebar_revealer.reveal_child = true;
  }

  private void hide_sidebar() {
    sidebar_close_timeout = 0;
    sidebar_revealer.reveal_child = false;
  }

  private void handle_pointer_motion(double x, double y) {
    var width = get_width();
    if (width <= 0) {
      return;
    }

    var sidebar_width = sidebar_revealer.get_width();
    var over_edge = x >= width - SIDEBAR_EDGE_WIDTH;
    var over_sidebar = sidebar_revealer.reveal_child
      && x >= width - sidebar_width - SIDEBAR_EDGE_WIDTH;

    if (over_edge || over_sidebar) {
      show_sidebar();
      return;
    }

    if (sidebar_revealer.reveal_child && sidebar_close_timeout == 0) {
      sidebar_close_timeout = GLib.Timeout.add(SIDEBAR_CLOSE_DELAY, () => {
        hide_sidebar();
        return GLib.Source.REMOVE;
      });
    }
  }

  private void add_player(AstalMpris.Player player) {
    var player_widget = new Kompass.Player(player);
    player_widget.vexpand = true;
    media_players.append(player_widget);
    media_panel.visible = true;
  }

  private void remove_player(AstalMpris.Player player) {
    Gtk.Widget? child = media_players.get_first_child();
    while (child != null) {
      Gtk.Widget? next = child.get_next_sibling();
      var player_widget = child as Kompass.Player;
      if (player_widget != null && player_widget.player == player) {
        media_players.remove(child);
        break;
      }
      child = next;
    }

    media_panel.visible = media_players.get_first_child() != null;
  }

  private void update_clock() {
    var now = new GLib.DateTime.now_local();
    time.label = now.format("%H:%M");
    date.label = now.format("%A, %d %B");
  }

  [GtkCallback]
  public void authenticate() {
    var response = secret_input.visible ? secret_input.text : visible_input.text;
    app.authenticate();
    app.submit_response(response);
  }

  construct {
    var username = Environment.get_user_name();
    user.label = username;

    speaker = AstalWp.get_default().audio.default_speaker;
    screen = AstalBrightness.get_default().screen;
    battery = AstalBattery.Device.get_default();
    setup_media_players();

    pointer_motion = new Gtk.EventControllerMotion();
    pointer_motion.motion.connect(handle_pointer_motion);
    add_controller(pointer_motion);

    clock_interval = GLib.Timeout.add(15000, () => {
      update_clock();
      return GLib.Source.CONTINUE;
    });

    update_clock();
  }

  public override void dispose() {
    GLib.Source.remove(clock_interval);
    if (sidebar_close_timeout != 0) {
      GLib.Source.remove(sidebar_close_timeout);
    }
    base.dispose();
  }
}
}
