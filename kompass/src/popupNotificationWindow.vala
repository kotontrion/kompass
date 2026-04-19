using GtkLayerShell;

public class KompassBar.PopupNotificationWindow : Kompass.Window {
  public AstalNotifd.Notifd notifd;

  private Gtk.ListBox notif_list;
  private GLib.ListModel notif_list_model;

  static construct {
    set_css_name("popup-notification-window");
  }

  public PopupNotificationWindow() {
    Object(
      application: KompassBar.Application.instance,
      name: "popup-notification",
      anchor: Kompass.WindowAnchor.BOTTOM |
      Kompass.WindowAnchor.LEFT,
      default_width: 500,
      default_height: -1
      );

    this.notifd = AstalNotifd.get_default();
    this.notif_list = new Gtk.ListBox() {
      selection_mode = Gtk.SelectionMode.NONE
    };

    this.set_content(this.notif_list);

    this.notifd.notified.connect((id, replace) => this.on_added(id, replace));
    this.notif_list_model = this.notif_list.observe_children();
    this.notif_list_model.items_changed.connect((list, position, removed, added) => {
      this.visible = list.get_n_items() > 0;
    });
  }

  private void on_added(uint id, bool replaced) {
    if (this.notifd.dont_disturb) {
      return;
    }
    if (replaced) {
      int i = 0;

      Kompass.PopupNotification? n = (Kompass.PopupNotification)this.notif_list.get_row_at_index(0);
      while (n != null) {
        if (n.notification.notification.id == id) {
          n.notification.notification = this.notifd.get_notification(id);
          break;
        }
        n = (Kompass.PopupNotification)this.notif_list.get_row_at_index(++i);
      }
    } else {
      var notif = new Kompass.PopupNotification(
        this.notifd.get_notification(id),
        Kompass.PopupNotificationTransitionType.IN_BOTTOM_OUT_LEFT);
      notif.closed.connect(() => {
        this.notif_list.remove(notif);
      });
      this.notif_list.append(notif);
    }
  }
}
