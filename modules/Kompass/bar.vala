
namespace Kompass {

class Bar : Astal.Window {

  private Astal.CenterBox center_box;
  public bool vertical {get; construct; default=false;}
  public unowned List<weak Gtk.Widget> start_widgets {get; construct;}
  public unowned List<weak Gtk.Widget> center_widgets {get; construct;}
  public unowned List<weak Gtk.Widget> end_widgets {get; construct;}

  construct {
    this.center_box = new Astal.CenterBox();
    this.center_box.vertical = this.vertical;

    Astal.Box sb = new Astal.Box(this.vertical, this.start_widgets);
    this.center_box.start_widget = sb;
    
    Astal.Box cb = new Astal.Box(this.vertical, this.center_widgets);
    this.center_box.start_widget = cb;
    if(this.vertical) cb.valign = Gtk.Align.END;
    else cb.halign = Gtk.Align.END;
    
    Astal.Box eb = new Astal.Box(this.vertical, this.end_widgets);
    this.center_box.start_widget = eb;
    if(this.vertical) eb.valign = Gtk.Align.END;
    else eb.halign = Gtk.Align.END;

    this.add(center_box);
    this.show_all();
  }


}
}

