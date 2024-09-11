
namespace Kompass {

class Clock : Astal.EventBox {

  private uint interval_id;
  private Astal.Label label;
  private bool hover_state = false;

  public int interval { get; construct; default=1; }
  public string format { get; construct; }
  public string hover_format { get; construct; }


  private void update_clock() {
    GLib.DateTime now = new GLib.DateTime.now_local();
    this.label.label = now.format(hover_state ? this.hover_format : this.format);
  }

  construct {

    if(this.format == null) this.format = "%T";
    if(this.hover_format == null) this.hover_format = "%a %F";
   
    this.label = new Astal.Label();
    this.add(this.label);
    
    this.interval_id = GLib.Timeout.add (this.interval*1000, () => {
      this.update_clock();
      return GLib.Source.CONTINUE;
    });
    
    this.update_clock();

    this.hover.connect(() => {
      this.hover_state = true;
      this.update_clock();
    });
    this.hover_lost.connect(() => {
      this.hover_state = false;
      this.update_clock();
    });


  }

  public override void dispose() {
    GLib.Source.remove(this.interval_id);
    base.dispose();
  }

}
}

