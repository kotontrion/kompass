public enum Kompass.ScrollBehaviour {
  ALTERNATE,
  SLIDE
}

public class Kompass.ScrollingLabel : Gtk.Widget {
  private Gtk.Label scroll_label;
  private double position = 0;
  private int scroll_direction = -1;
  private int64 last_time = 0;
  private int64 delay = 0;

  public double speed { get; set; default = 0.5; }

  public int direction_change_delay { get; set; default = 500; }

  public Gtk.Orientation direction { get; set; default = Gtk.Orientation.HORIZONTAL; }

  public Kompass.ScrollBehaviour behaviour { get; set; default = Kompass.ScrollBehaviour.ALTERNATE; }

  public string label {
    get { return this.scroll_label.label; }
    set { this.scroll_label.label = value; }
  }

  construct {
    this.scroll_label = new Gtk.Label("");

    this.overflow = Gtk.Overflow.HIDDEN;

    this.scroll_label.set_parent(this);
    this.add_tick_callback(update_position);
  }

  protected override void measure(Gtk.Orientation orientation,
                                  int for_size,
                                  out int minimum,
                                  out int natural,
                                  out int minimum_baseline,
                                  out int natural_baseline) {
    int min = 0;
    int nat = 0;

    this.scroll_label.measure(orientation, -1, out min, out nat, null, null);
    minimum = 0;
    natural = nat;
    minimum_baseline = -1;
    natural_baseline = -1;
  }

  protected override void size_allocate(int width, int height, int baseline) {
    int child_width = 0;
    int child_height = 0;

    Gtk.Requisition child_req;
    this.scroll_label.get_preferred_size(out child_req, null);

    child_width = child_req.width;
    child_height = child_req.height;
    if (this.direction == Gtk.Orientation.HORIZONTAL) {
      this.scroll_label.allocate_size({ (int)this.position, 0, child_width, child_height }, -1);
    } else {
      this.scroll_label.allocate_size({ 0, (int)this.position, child_width, child_height }, -1);
    }
  }

  protected override Gtk.SizeRequestMode get_request_mode() {
    return Gtk.SizeRequestMode.CONSTANT_SIZE;
  }

  private bool update_position(Gtk.Widget widget, Gdk.FrameClock clock) {
    int64 current_time = clock.get_frame_time();

    if (this.last_time == 0) {
      this.last_time = current_time;
      return Source.CONTINUE;
    }

    int64 elapsed = current_time - this.last_time;
    this.last_time = current_time;
    double delta = this.speed * elapsed / 10000;

    bool is_horizontal = (this.direction == Gtk.Orientation.HORIZONTAL);
    double limit = is_horizontal ? this.get_width() : this.get_height();
    double label_size = is_horizontal ? this.scroll_label.get_width() : this.scroll_label.get_height();

    if (this.delay >= 0) {
      this.delay += elapsed / 1000;
      if (this.delay > this.direction_change_delay) {
        this.delay = -1;
      } else {
        return Source.CONTINUE;
      }
    }

    if (this.behaviour == Kompass.ScrollBehaviour.ALTERNATE) {
      if (this.scroll_direction < 0) {
        if (this.position + label_size > limit) {
          this.position = double.max(limit - label_size, this.position - delta);
        } else {
          this.scroll_direction = 1;
          this.delay = 0;
        }
      } else {
        if (this.position < 0) {
          this.position = double.min(0, this.position + delta);
        } else {
          this.scroll_direction = -1;
          this.delay = 0;
        }
      }
    } else {
      if (this.position + label_size > 0) {
        this.position -= delta;
      } else {
        this.position = limit;
      }
    }

    this.queue_resize();
    return Source.CONTINUE;
  }

  ~ScrollingLabel() {
    this.scroll_label.unparent();
  }
}
