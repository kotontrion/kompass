
namespace Kompass {

class VClock : Astal.Box {

  private uint interval_id;
  private Astal.Label hour;
  private Astal.Label minute;

  public int interval { get; construct; default=1; }
  
  private void update_clock() {
    GLib.DateTime now = new GLib.DateTime.now_local();
    this.hour.label = now.format("%H");
    this.minute.label = now.format("%M");
  }

  construct {

    this.vertical = true;

    Astal.widget_set_class_names(this, {"clock"});

    this.hour = new Astal.Label();
    this.minute = new Astal.Label();
    this.add(this.hour);
    this.add(this.minute);
    
    this.interval_id = GLib.Timeout.add (this.interval*1000, () => {
      this.update_clock();
      return GLib.Source.CONTINUE;
    });
    
    this.update_clock();
  }

  public override void dispose() {
    GLib.Source.remove(this.interval_id);
    base.dispose();
  }

  public VClock(bool vertical, List<weak Gtk.Widget> children) {
    base(vertical, children);
  }

}
}

