using GtkLayerShell;

private class PopupNotification : Gtk.ListBoxRow {
  private Gtk.Revealer outer_revealer;
  private Gtk.Revealer inner_revealer;
  private Gtk.Box notification_box;

  private Kompass.Notification notification;

  public AstalNotifd.Notifd notifd;
  public int animation_duration { get; set; default = 500; }
  public int timeout { get; set; default = 5000; }

  public PopupNotification(AstalNotifd.Notification notification) {
    this.notifd = AstalNotifd.get_default();
    this.notification = new Kompass.Notification(notification);

    this.selectable = false;
    this.activatable = false;

    this.notification_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

    this.outer_revealer = new Gtk.Revealer() {
      transition_type = Gtk.RevealerTransitionType.SLIDE_UP,
      transition_duration = this.animation_duration,
      reveal_child = false,
    };

    this.inner_revealer = new Gtk.Revealer() {
      transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
      transition_duration = this.animation_duration,
      reveal_child = true,
    };

    this.inner_revealer.set_child(this.notification);
    this.outer_revealer.set_child(this.inner_revealer);
    this.notification_box.append(this.outer_revealer);
    this.set_child(this.notification_box);

    this.inner_revealer.notify["child-revealed"].connect(() => {
      if (!this.inner_revealer.reveal_child) {
        this.outer_revealer.reveal_child = false;
      }
    });

    this.outer_revealer.notify["child-revealed"].connect(() => {
      if (!this.outer_revealer.reveal_child) {
        (this.parent as Gtk.ListBox).remove(this);
      }
    });

    this.notifd.resolved.connect((id, reason) => {
      if (id == notification.id) {
        this.inner_revealer.reveal_child = false;
      }
    });

    this.realize.connect(() => {
      GLib.Idle.add(() => {
        this.outer_revealer.reveal_child = true;
        return GLib.Source.REMOVE;
      });
      GLib.Timeout.add(this.timeout, () => {
        this.inner_revealer.reveal_child = false;
        return GLib.Source.REMOVE;
      });
    });
  }
}

public class KompassBar.PopupNotificationWindow : Astal.Window {
  public AstalNotifd.Notifd notifd;

  private Gtk.ListBox notif_list;

  static construct {
    set_css_name("popup-notification-window");
  }

  public PopupNotificationWindow() {
    Object(
      application: KompassBar.Application.instance,
      name: "popup-notification",
      anchor: Astal.WindowAnchor.BOTTOM |
      Astal.WindowAnchor.LEFT,
      default_width: -1,
      default_height: -1,
      visible: true
      );

    this.notifd = AstalNotifd.get_default();
    this.notif_list = new Gtk.ListBox() {
      selection_mode = Gtk.SelectionMode.NONE
    };

    this.set_child(this.notif_list);

    this.notifd.notified.connect((id, replace) => this.on_added(id, replace));
  }

  private void on_added(uint id, bool replaced) {
    this.notif_list.append(new PopupNotification(this.notifd.get_notification(id)));
  }
}
