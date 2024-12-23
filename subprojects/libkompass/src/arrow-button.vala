[GtkTemplate(ui = "/com/github/kotontrion/libkompass/ui/arrow-button.ui")]
public class Kompass.ArrowButton : Gtk.Box {
  public string icon { get; set; }
  public string label { get; set; }
  public string tag { get; set; }
  public bool active {
    get {
      return this.has_css_class("active");
    }
    set {
      if (value) {
        this.add_css_class("active");
      } else {
        this.remove_css_class("active");
      }
    }
  }

  public bool inactive {
    get {
      return !this.has_css_class("active");
    }
    set {
      if (value) {
        this.remove_css_class("active");
      } else {
        this.add_css_class("active");
      }
    }
  }

  public signal void clicked();
  public signal void arrow_clicked();

  [GtkCallback]
  public void on_clicked() {
    clicked();
  }

  [GtkCallback]
  public void on_arrow_clicked() {
    arrow_clicked();
  }

  static construct {
    set_css_name("arrow-button");
  }
}
