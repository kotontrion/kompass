using GtkLayerShell;

[GtkTemplate(ui = "/com/github/kotontrion/kompass/ui/bar.ui")]
public class Kompass.Bar : Astal.Window {
  public AstalRiver.Output output { get; private set; }

  public Bar(AstalRiver.Output output) {
    Object(
      application: Kompass.Application.instance,
      namespace : @"bar-$(output.name)",
      name: @"bar-$(output.name)",
      css_name: "bar",
      anchor: Astal.WindowAnchor.LEFT
      | Astal.WindowAnchor.TOP
      | Astal.WindowAnchor.BOTTOM
      );

    this.output = output;

    ListModel monitors = Gdk.Display.get_default().get_monitors();
    for (int i = 0; i < monitors.get_n_items(); i++) {
      Gdk.Monitor monitor = (Gdk.Monitor)monitors.get_item(i);
      if (monitor.connector == output.name) {
        set_monitor(this, monitor);
        break;
      }
    }
  }
}
