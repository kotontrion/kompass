[GtkTemplate(ui = "/com/github/kotontrion/kompass-bar/ui/notification.ui")]
public class Kompass.Notification : Gtk.ListBoxRow, Adw.Swipeable {
  public AstalNotifd.Notification notification { get; set; }

  private Adw.SwipeTracker swipe_tracker;
  private Adw.SpringAnimation animation;
  private Gtk.CssProvider css_prov;
  private double _sp = 0;
  public double swipe_progress {
    get { return _sp; }
    set {
      _sp = value;
      try {
        var s = value.abs();
        this.css_prov.load_from_string(@"* { 
            --swipe_progress: $(value.abs()); 
            --swipe: $(s); 
            }");
      } catch (Error err) {
        warning(err.message);
      }
    }
  }

  [GtkChild]
  private unowned Gtk.Box box;

  [GtkChild]
  private unowned Gtk.Box actions;

  [GtkCallback]
  public string time(int64 t) {
    DateTime dt = new DateTime.from_unix_local(t);

    return dt.format("%T");
  }

  [GtkCallback]
  public void close() {
    this.notification.dismiss();
  }

  private void setup_actions() {
    notification.actions.@foreach(a => {
      Gtk.Button action = new Gtk.Button();
      action.label = a.label;
      action.clicked.connect(() => this.notification.invoke(a.id));
      action.hexpand = true;
      action.add_css_class("notification-action");
      this.actions.append(action);
    });
  }

  public double get_cancel_progress() {
    return 0;
  }

  public double get_distance() {
    return this.get_width();
  }

  public double get_progress() {
    return swipe_progress;
  }

  public double[] get_snap_points() {
    return { -1, 0, 1 };
  }

  public Gdk.Rectangle get_swipe_area(Adw.NavigationDirection navigation_direction, bool is_drag) {
    return {
             0,
             0,
             this.get_width(),
             this.get_height()
    };
  }

  construct {
    this.css_prov = new Gtk.CssProvider();
    this.get_style_context()
      .add_provider(this.css_prov, Gtk.STYLE_PROVIDER_PRIORITY_USER);

    this.swipe_tracker = new Adw.SwipeTracker(this);
    this.swipe_tracker.allow_mouse_drag = true;
    this.swipe_tracker.end_swipe.connect((s, v, t) => {
      var target = new Adw.CallbackAnimationTarget((v) => {
        swipe_progress = v;
        box.set_margin_start((int)(this.get_width() * v));
        box.set_margin_end((int)(-this.get_width() * v));
      });
      this.animation = new Adw.SpringAnimation(this, swipe_progress, t, new Adw.SpringParams(0.7, 1.0, 50.0), target) {
        initial_velocity = v,
        clamp = t != 0
      };
      animation.done.connect(() => {
        if (swipe_progress != 0) {
          this.notification.dismiss();
        }
      });
      animation.play();
    });
    this.swipe_tracker.begin_swipe.connect((s) => {
      if (this.animation != null) {
        animation.pause();
        animation = null;
      }
    });
    this.swipe_tracker.update_swipe.connect((s, p) => {
      this.swipe_progress = p;
      box.set_margin_start((int)(this.get_width() * p));
      box.set_margin_end((int)(-this.get_width() * p));
    });
  }

  public Notification(AstalNotifd.Notification notification) {
    Object(notification: notification);
    this.setup_actions();
  }
}
