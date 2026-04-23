public class Kompass.AnimatedLevelBar : Adw.Bin, Gtk.Orientable {
  private Gtk.LevelBar level_bar;
  private Adw.TimedAnimation animation;

  public bool inverted {
    get { return this.level_bar.inverted; }
    set { this.level_bar.inverted = value; }
  }
  public double max_value {
    get { return this.level_bar.max_value; }
    set { this.level_bar.max_value = value; }
  }
  public double min_value {
    get { return this.level_bar.min_value; }
    set { this.level_bar.min_value = value; }
  }
  public Gtk.LevelBarMode mode {
    get { return this.level_bar.mode; }
    set { this.level_bar.mode = value; }
  }
  public double value {
    get { return this.animation.value_to; }
    set {
      this.animation.value_from = this.level_bar.value;
      this.animation.value_to = value;
      this.animation.play();
    }
  }
  public Gtk.Orientation orientation {
    get { return this.level_bar.orientation; }
    set { this.level_bar.orientation = value; }
  }

  public uint duration {
    get { return this.animation.duration; }
    set { this.animation.duration = value; }
  }
  public Adw.Easing easing {
    get { return this.animation.easing; }
    set { this.animation.easing = value; }
  }

  construct {
    this.level_bar = new Gtk.LevelBar();
    level_bar.remove_offset_value(Gtk.LEVEL_BAR_OFFSET_LOW);
    level_bar.remove_offset_value(Gtk.LEVEL_BAR_OFFSET_HIGH);
    level_bar.remove_offset_value(Gtk.LEVEL_BAR_OFFSET_FULL);
    this.set_child(level_bar);
    this.animation = new Adw.TimedAnimation(this.level_bar, 0, 0, 250, new Adw.PropertyAnimationTarget(this.level_bar, "value"));
  }
}
