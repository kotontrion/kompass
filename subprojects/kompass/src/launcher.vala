[GtkTemplate(ui = "/com/github/kotontrion/kompass-bar/ui/launcher.ui")]
public class KompassBar.Launcher : Gtk.Box {
  public AstalApps.Apps apps { get; construct set; }

  [GtkChild]
  private unowned Gtk.Popover popover;

  [GtkChild]
  private unowned Gtk.ListBox app_list;

  [GtkChild]
  private unowned Gtk.Entry entry;

  [GtkCallback]
  public void open_launcher() {
    this.entry.text = "";
    this.popover.popup();
  }

  [GtkCallback]
  public void launch_first() {
    KompassBar.AppButton ab = (KompassBar.AppButton)this.app_list.get_row_at_index(0);

    if (ab != null) {
      ab.activate();
    }
  }

  private int sort_func(Gtk.ListBoxRow la, Gtk.ListBoxRow lb) {
    KompassBar.AppButton a = (KompassBar.AppButton)la;
    KompassBar.AppButton b = (KompassBar.AppButton)lb;

    if (a.score == b.score) {
      return b.app.frequency - a.app.frequency;
    }
    return (a.score > b.score) ? -1 : 1;
  }

  private bool filter_func(Gtk.ListBoxRow la) {
    KompassBar.AppButton a = (KompassBar.AppButton)la;

    return a.score >= 0;
  }

  [GtkCallback]
  public void update_list() {
    int i = 0;

    KompassBar.AppButton? app = (KompassBar.AppButton)this.app_list.get_row_at_index(0);
    while (app != null) {
      app.score = apps.fuzzy_score(this.entry.text, app.app);
      app = (KompassBar.AppButton)this.app_list.get_row_at_index(++i);
    }
    this.app_list.invalidate_sort();
    this.app_list.invalidate_filter();
  }

  construct {
    this.apps = new AstalApps.Apps();

    this.app_list.set_sort_func(sort_func);
    this.app_list.set_filter_func(filter_func);

    this.apps.list.@foreach(app => {
      this.app_list.append(new AppButton(app));
    });
  }
}
