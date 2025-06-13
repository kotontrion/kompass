namespace Kompass {
public enum CavaStyle {
  /** draw as a smooth curve */
  SMOOTH,
  /** like smooth, but better */
  CATMULL_ROM
}

public class Cava : Gtk.Widget {

  public AstalCava.Cava cava {get; construct;}
  public CavaStyle style { get; set; default = CavaStyle.CATMULL_ROM; }

  private AstalWp.Endpoint default_speaker;

  public Cava.with_cava(AstalCava.Cava cava) {
    Object(cava: cava);
  }

  construct {

    if(this.cava == null) {
      this.cava = AstalCava.get_default();
    }

    this.default_speaker = AstalWp.get_default().get_default_speaker();

    this.default_speaker.notify["serial"].connect(() => {
        this.cava.source = @"$(this.default_speaker.serial)";
    });

    this.cava.notify["values"].connect(() => this.queue_draw());
  }

  class construct {
    set_css_name("cava");
  }

  public override void snapshot(Gtk.Snapshot snapshot) {
    base.snapshot(snapshot);
    switch (style) {
      case SMOOTH:
        draw_smooth(snapshot);
        break;

      case CATMULL_ROM:
      default:
        draw_catmull_rom(snapshot);
        break;
    }
  }

  private void draw_catmull_rom(Gtk.Snapshot snapshot) {
    int width = this.get_width();
    int height = this.get_height();
    Gdk.RGBA color = this.get_color();

    Array<double> values = cava.get_values();
    int bars = cava.bars;

    float bar_width = width / (bars - 1f);

    Gsk.PathBuilder builder = new Gsk.PathBuilder();
    builder.move_to(0, (float)(height - height * values.index(0)));

    for (int i = 0; i <= bars - 2; i++) {
      Graphene.Point p0, p1, p2, p3;

      if (i == 0) {
        p0 = { x : i* bar_width, y : (float)(height - height * values.index(i)) };
        p3 = { x : (i + 2) * bar_width, y : (float)(height - height * values.index(i + 2)) };
      } else if (i == bars - 2) {
        p0 = { x : (i - 1) * bar_width, y : (float)(height - height * values.index(i - 1)) };
        p3 = { x : (i + 1) * bar_width, y : (float)(height - height * values.index(i + 1)) };
      } else {
        p0 = { x : (i - 1) * bar_width, y : (float)(height - height * values.index(i - 1)) };
        p3 = { x : (i + 2) * bar_width, y : (float)(height - height * values.index(i + 2)) };
      }

      p1 = { x : i* bar_width, y : (float)(height - height * values.index(i)) };
      p2 = { x : (i + 1) * bar_width, y : (float)(height - height * values.index(i + 1)) };

      Graphene.Point c1 = { x : p1.x + (p2.x - p0.x) / 6, y : p1.y + (p2.y - p0.y) / 6 };
      Graphene.Point c2 = { x : p2.x - (p3.x - p1.x) / 6, y : p2.y - (p3.y - p1.y) / 6 };

      builder.cubic_to(c1.x, c1.y, c2.x, c2.y, p2.x, p2.y);
    }

    builder.line_to(width, height);
    builder.line_to(0, height);

    builder.close();

    snapshot.append_fill(builder.to_path(), Gsk.FillRule.WINDING, color);
  }

  private void draw_smooth(Gtk.Snapshot snapshot) {
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
}
