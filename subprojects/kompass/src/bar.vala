using GtkLayerShell;

[GtkTemplate(ui = "/com/github/kotontrion/kompass-bar/ui/bar.ui")]
public class KompassBar.Bar : Astal.Window {
  public AstalRiver.Output output { get; private set; }

  public Bar(Gdk.Monitor monitor) {
    Object(
      application: KompassBar.Application.instance,
      namespace : @"bar-$(monitor.get_connector())",
      name: @"bar-$(monitor.get_connector())",
      css_name: "bar",
      gdkmonitor: monitor,
      anchor: Astal.WindowAnchor.LEFT
      | Astal.WindowAnchor.TOP
      | Astal.WindowAnchor.BOTTOM
      );

    var river = AstalRiver.get_default();
    if (river != null) {
      this.output = river.get_output(monitor.get_connector());
      //HACK: gdk already knows about the new monitor, but river does not.
      //a wl_display_sync in the river lib might fix that.
      if (this.output == null) {
        river.output_added.connect((riv, name) => {
          if (name == monitor.get_connector()) {
            this.output = river.get_output(name);
          }
        });
      }
    }
  }
}
