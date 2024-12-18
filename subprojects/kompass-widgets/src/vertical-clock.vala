[GtkTemplate(ui = "/com/github/kotontrion/kompass-widgets/ui/vertical-clock.ui")]
public class Kompass.VerticalClock : Gtk.Box {
  private uint interval_id;

  [GtkChild]
  private unowned Gtk.Label hour;
  [GtkChild]
  private unowned Gtk.Label minute;
  [GtkChild]
  private unowned Gtk.Label day;
  [GtkChild]
  private unowned Gtk.Label year;

  private void update_clock() {
    GLib.DateTime now = new GLib.DateTime.now_local();
    this.hour.label = now.format("%H");
    this.minute.label = now.format("%M");
    this.day.label = now.format("%d%m");
    this.year.label = now.format("%Y");
  }

  construct {
    this.interval_id = GLib.Timeout.add(15000, () => {
      this.update_clock();
      return GLib.Source.CONTINUE;
    });

    this.update_clock();
  }

  public override void dispose() {
    GLib.Source.remove(this.interval_id);
    base.dispose();
  }
}
