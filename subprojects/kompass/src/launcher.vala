[GtkTemplate(ui = "/com/github/kotontrion/kompass-bar/ui/launcher.ui")]
public class KompassBar.Launcher : Gtk.Box {
  public AstalApps.Apps apps { get; construct set; }

  [GtkChild]
  private unowned Gtk.Popover popover;

  [GtkChild]
  private unowned Kompass.Launcher launcher;

  // [GtkChild]
  // private unowned Gtk.ListBox app_list;
  //
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
  // private int sort_func(Gtk.ListBoxRow la, Gtk.ListBoxRow lb) {
  //   Kompass.AppButton a = (Kompass.AppButton)la;
  //   Kompass.AppButton b = (Kompass.AppButton)lb;
  //
  //   if (a.score == b.score) {
  //     return b.app.frequency - a.app.frequency;
  //   }
  //   return (a.score > b.score) ? -1 : 1;
  // }
  //
  // private bool filter_func(Gtk.ListBoxRow la) {
  //   Kompass.AppButton a = (Kompass.AppButton)la;
  //
  //   return a.score >= 0;
  // }
  //
  [GtkCallback]
  public void update_list() {
    this.launcher.search(this.entry.text);
  }
}
