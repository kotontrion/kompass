public class Kompass.Cava : Gtk.Widget {
  private AstalCava.Cava cava;

  construct {
    this.cava = AstalCava.get_default();
    cava.notify["values"].connect(() => this.queue_draw());
  }

  class construct {
    set_css_name("cava");
  }

  public override void snapshot(Gtk.Snapshot snapshot) {
    base.snapshot(snapshot);

    int width = this.get_width();
    int height = this.get_height();
    Gdk.RGBA color = this.get_color();

    Array<double> values = cava.get_values();
    int bars = cava.bars;

    Gsk.PathBuilder builder = new Gsk.PathBuilder();
    float last_x = 0;
    float last_y = (float)(height - height * (values.index(0)));
    float bar_width = width / (bars - 1f);
    builder.move_to(last_x, last_y);
    for (int i = 1; i < bars; i++) {
      float h = (float)(height * (values.index(i)));
      float y = height - h;
      builder.cubic_to(last_x + bar_width / 2, last_y, last_x + bar_width / 2, y, i * bar_width, y);
      last_x = i * bar_width;
      last_y = y;
    }
    builder.line_to(last_x, height);
    builder.line_to(0, height);

    builder.close();

    snapshot.append_fill(builder.to_path(), Gsk.FillRule.WINDING, color);
  }
}
