[GtkTemplate(ui = "/com/github/kotontrion/kompass-bar/ui/launcher.ui")]
public class KompassBar.Launcher : Gtk.Box {
  public AstalApps.Apps apps { get; construct set; }

  [GtkChild]
  private unowned Gtk.Popover popover;

  [GtkChild]
  private unowned Kompass.Launcher launcher;

  [GtkChild]
  private unowned Gtk.Entry entry;

  [GtkCallback]
  public void open_launcher() {
    this.entry.text = "";
    this.popover.popup();
  }

  [GtkCallback]
  public void launch_first() {
    this.popover.popdown();
    this.launcher.launch_first();
  }

  [GtkCallback]
  public void update_list() {
    this.launcher.search(this.entry.text);
  }
}
