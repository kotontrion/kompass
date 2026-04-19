namespace Kompass {
/**
 * A button with an attached arrow as a secondary button.
 * Eg clicking the main button could toggle bluetooth and clicking the arrow
 * opens the bluetooth settings.
 *
 * ![arrow-button](arrow-button.jpg)
 *
 * ## CSS nodes
 *
 * `KompassArrowButton`'s CSS node is called `arrow-button`. The `active` class
 * is controled by the `active` property.
 */
[GtkTemplate(ui = "/com/github/kotontrion/libkompass/ui/arrow-button.ui")]
public class ArrowButton : Gtk.Box {
  public string icon { get; set; }
  public string label { get; set; }
  public string subtitle { get; set; }

  /**
   * controls the `active` css class
   */
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

  /**
   * The inverse of [property@Kompass.ArrowButton:active]. This is useful
   * because eg blueprint does not suport the inverted flag for nested
   * bidirectional property bindings.
   */
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
  private bool is_not_empty(string text) {
    return text != null && text != "";
  }

  [GtkCallback]
  private void on_clicked() {
    clicked();
  }

  [GtkCallback]
  private void on_arrow_clicked() {
    arrow_clicked();
  }

  static construct {
    set_css_name("arrow-button");
  }
}
}
