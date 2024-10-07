[GtkTemplate (ui = "/com/github/kotontrion/kompass/ui/notification.ui")]
public class Kompass.Notification : Gtk.Box {

    public AstalNotifd.Notification notification {get; set;}

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

    public Notification(AstalNotifd.Notification notification) {
        Object(notification: notification);
        this.setup_actions();
    }
}
