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

  // [GtkCallback]
  // public void launch_first() {
  //   Kompass.AppButton ab = (Kompass.AppButton)this.app_list.get_row_at_index(0);
  //
  //   if (ab != null) {
  //     ab.activate();
  //   }
  // }
  //

  [GtkCallback]
  public void update_list() {
    this.launcher.search(this.entry.text);
  }
}
