[GtkTemplate(ui = "/com/github/kotontrion/libkompass/ui/audio-endpoint.ui")]
public class Kompass.AudioNode : Gtk.ListBoxRow {
  public AstalWp.Node endpoint { get; construct; }

  [GtkChild]
  private unowned Gtk.Adjustment volume_adjust;

  [GtkCallback]
  public string icon_substitue(string icon) {
    switch (icon) {
      case "audio-card-analog-pci":
        return "audio-card-symbolic";

      case "audio-headset-bluetooth":
        return "audio-headset-symbolic";

      default:
        return icon;
    }
  }

  [GtkCallback]
  public void clicked() {
    if (this.endpoint is AstalWp.Endpoint) {
      (this.endpoint as AstalWp.Endpoint).is_default = true;
    }
  }

  public AudioNode(AstalWp.Node endpoint) {
    Object(endpoint: endpoint);
    this.endpoint.bind_property("volume", volume_adjust, "value",
                                GLib.BindingFlags.BIDIRECTIONAL | GLib.BindingFlags.SYNC_CREATE);
  }
}
