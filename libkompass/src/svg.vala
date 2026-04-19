namespace Kompass {
public class Svg : Adw.Bin {
  public string resource {
    owned get { return this.svg.resource; }
    set { this.svg.resource = value; }
  }

  public bool playing {
    get { return this.svg.playing; }
    set { this.svg.playing = value; }
  }

  private uint _state;
  public uint state {
    get { return this.svg.state; }
    set {
      this._state = value;
      if (this.get_realized()) {
        this.svg.state = value;
      }
    }
  }

  public Gtk.IconSize icon_size {
    get { return this.image.icon_size; }
    set { this.image.icon_size = value; }
  }

  private Gtk.Svg svg;
  private Gtk.Image image;

  construct {
    this.svg = new Gtk.Svg();

    this.image = new Gtk.Image() {
      paintable = this.svg
    };

    this.set_child(image);
    this.realize.connect(() => {
        this.svg.set_frame_clock(this.get_frame_clock());
        this.svg.play();
        this.svg.set_state(this._state);
      });
  }
}
}
