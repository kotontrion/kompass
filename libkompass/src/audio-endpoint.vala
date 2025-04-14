[GtkTemplate(ui = "/com/github/kotontrion/libkompass/ui/audio-endpoint.ui")]
public class Kompass.AudioEndpoint : Gtk.ListBoxRow {
  public AstalWp.Endpoint endpoint { get; construct; }

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
    this.endpoint.is_default = true;
  }

  public AudioEndpoint(AstalWp.Endpoint endpoint) {
    Object(endpoint: endpoint);
    this.endpoint.bind_property("volume", volume_adjust, "value",
                                GLib.BindingFlags.BIDIRECTIONAL | GLib.BindingFlags.SYNC_CREATE);
  }
}
