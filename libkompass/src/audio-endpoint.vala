[GtkTemplate(ui = "/net/kotontrion/libkompass/ui/audio-endpoint.ui")]
public class Kompass.AudioNode : Gtk.ListBoxRow {
  public AstalWp.Node endpoint { get; construct; }

  [GtkChild]
  private unowned Gtk.Adjustment volume_adjust;

  [GtkCallback]
  private string icon_substitue(string icon) {
    switch (icon) {
      case "audio-card-analog-pci":
      case "audio-card-analog-usb":
        return "audio-card-symbolic";

      case "audio-headset-bluetooth":
        return "audio-headset-symbolic";

      default:
        return icon;
    }
  }

  [GtkCallback]
  private void clicked() {
    if (this.endpoint is AstalWp.Endpoint) {
      (this.endpoint as AstalWp.Endpoint).is_default = true;
    }
  }

  public AudioNode(AstalWp.Node endpoint) {
    Object(endpoint: endpoint);
  }

  construct {
    this.endpoint.bind_property("volume", volume_adjust, "value",
                                GLib.BindingFlags.BIDIRECTIONAL | GLib.BindingFlags.SYNC_CREATE);
  }
}
