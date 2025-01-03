[GtkTemplate(ui = "/com/github/kotontrion/kompass-bar/ui/qsNotif.ui")]
public class KompassBar.QsNotif : Gtk.Box {
  public AstalNotifd.Notifd notifd { get; construct set; }

  [GtkChild]
  private unowned Gtk.ListBox notifications;

  [GtkCallback]
  public void clear() {
    this.notifd.notifications.@foreach(n => n.dismiss());
  }

  private void on_added(uint id, bool replaced, Gtk.ListBox lb) {
    if (replaced) {
      this.on_removed(id, lb);
    }
    lb.prepend(new KompassBar.Notification(notifd.get_notification(id)));
  }

  private void on_removed(uint id, Gtk.ListBox lb) {
    int i = 0;

    KompassBar.Notification? n = (KompassBar.Notification)lb.get_row_at_index(0);
    while (n != null) {
      if (n.notification.id == id) {
        lb.remove(n);
        break;
      }
      n = (KompassBar.Notification)lb.get_row_at_index(++i);
    }
  }

  construct {
    this.notifd = AstalNotifd.get_default();

    this.notifd.notifications.@foreach(n => this.on_added(n.id, false, this.notifications));
    this.notifd.notified.connect((id, replace) => this.on_added(id, replace, this.notifications));
    this.notifd.resolved.connect((id) => this.on_removed(id, this.notifications));
  }
}
