
namespace ValaLabel{

class Label : Astal.Box {

  public string label {get; set construct;}
  private Astal.Label label1;
  private Astal.Label label2;


  construct {
    this.label1 = new Astal.Label();
    this.label1.label = "from vala";
    this.label2 = new Astal.Label();
    this.label2.label = this.label;

    this.add(label2);
    this.add(label1);
    this.show_all();
  }

  public Label(bool vertical, List<weak Gtk.Widget> children) {
    base(vertical, children);
  }

}
}

public void init() {
  // register the type, is done automatically in most cases
  // typeof(ValaLabel.Label).ensure();
}

public void deinit() {
}
