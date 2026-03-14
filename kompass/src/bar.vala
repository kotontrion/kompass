using GtkLayerShell;

[GtkTemplate(ui = "/com/github/kotontrion/kompass-bar/ui/bar.ui")]
public class KompassBar.Bar : Astal.Window {
  public AstalRiver.Output output { get; private set; }

  public Bar(Gdk.Monitor monitor) {
    Object(
      application: KompassBar.Application.instance,
      namespace : @"bar",
      name: @"bar-$(monitor.get_connector())",
      css_name: "bar",
      gdkmonitor: monitor
      );

    if (AstalRiver.is_supported()) {
      var river = AstalRiver.get_default();
      this.output = river.find_output_by_name(monitor.get_connector());
      //HACK: gdk already knows about the new monitor, but river does not.
      //a wl_display_sync in the river lib might fix that.
      if (this.output == null) {
        river.output_added.connect((riv, output) => {
          if (output.output.name == monitor.get_connector()) {
            this.output = output;
          }
        });
      }
    }
  }
}
