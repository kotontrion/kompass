namespace Kompass {
public enum PopupNotificationTimeoutBehaviour {
  /**
   * use the timeout set by the notification if set, otherwise use the value of the timeout property
   */
  DEFAULT,

  /**
   * always use the value of the timeout property, ignore the timeout set by the notification
   */
  FORCE,

  /**
   * use the timeout set by the notification if set or the value of the timeout property, whichever value is higher
   */
  MIN,

  /**
   * use the timeout set by the notification if set or the value of the timeout property, whichever value is lower
   */
  MAX,
}

public enum PopupNotificationTransitionType {
  NONE,
  IN_BOTTOM_OUT_LEFT,
  IN_LEFT_OUT_LEFT,
  //TODO: add more
}

[GtkTemplate(ui = "/net/kotontrion/libkompass/ui/popup-notification.ui")]
public class PopupNotification : Gtk.ListBoxRow {
  [GtkChild]
  private unowned Gtk.Revealer outer_revealer;
  [GtkChild]
  private unowned Gtk.Revealer inner_revealer;

  public Kompass.Notification notification { get; construct set; }

  private AstalNotifd.Notifd notifd = AstalNotifd.get_default();
  public int animation_duration { get; construct set; default = 500; }
  public int timeout { get; construct set; default = 5000; }
  public PopupNotificationTimeoutBehaviour timeout_behaviour { get; construct set; default = PopupNotificationTimeoutBehaviour.DEFAULT; }
  public PopupNotificationTransitionType transition_type { get; construct set; default = PopupNotificationTransitionType.NONE; }

  public signal void closed();

  public PopupNotification(AstalNotifd.Notification notification, PopupNotificationTransitionType transition_type) {
    var notif = new Kompass.Notification(notification) {
      is_popup = true,
    };
    Object(notification: notif, transition_type: transition_type);
  }

  private void show_notif() {
    this.outer_revealer.reveal_child = true;

    uint timeout;
    int notif_timeout = this.notification.notification.expire_timeout;
    switch (this.timeout_behaviour) {
      case FORCE:
        timeout = this.timeout;
        break;

      case MIN:
        timeout = uint.max(this.timeout, notif_timeout);
        break;

      case MAX:
        timeout = uint.min(this.timeout, notif_timeout);
        break;

      case DEFAULT:
      default:
        timeout = notif_timeout > 0 ? notif_timeout : this.timeout;
        break;
    }
    GLib.Timeout.add_once(timeout, () => {
        this.hide_notif();
      });
  }

  private void hide_notif() {
    this.inner_revealer.reveal_child = false;
  }

  private void configure_revealers() {
    switch (this.transition_type) {
      case IN_BOTTOM_OUT_LEFT:
        this.outer_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        this.outer_revealer.reveal_child = false;
        this.inner_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
        this.inner_revealer.reveal_child = true;
        break;

      case IN_LEFT_OUT_LEFT:
        this.outer_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        this.outer_revealer.reveal_child = false;
        this.inner_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
        this.inner_revealer.reveal_child = false;
        break;

      case NONE:
      default:
        this.outer_revealer.transition_type = Gtk.RevealerTransitionType.NONE;
        this.outer_revealer.reveal_child = true;
        this.inner_revealer.transition_type = Gtk.RevealerTransitionType.NONE;
        this.inner_revealer.reveal_child = true;
        break;
    }
  }

  construct {
    this.configure_revealers();

    this.inner_revealer.set_child(this.notification);

    this.inner_revealer.notify["child-revealed"].connect(() => {
        if (!this.inner_revealer.reveal_child) {
          this.outer_revealer.reveal_child = false;
          if (!this.outer_revealer.child_revealed) {
            this.closed();
          }
        }
      });

    this.outer_revealer.notify["child-revealed"].connect(() => {
        if (!this.outer_revealer.reveal_child) {
          this.closed();
        } else {
          this.inner_revealer.reveal_child = true;
        }
      });

    this.notifd.resolved.connect((id, reason) => {
        if (id == notification.notification.id) {
          this.inner_revealer.reveal_child = false;
        }
      });

    this.realize.connect(() => {
        GLib.Idle.add(() => {
          this.show_notif();
          return GLib.Source.REMOVE;
        });
      });
  }
}
}
