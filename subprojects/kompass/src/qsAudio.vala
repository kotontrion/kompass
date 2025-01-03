[GtkTemplate(ui = "/com/github/kotontrion/kompass-bar/ui/qsAudio.ui")]
public class KompassBar.QsAudio : Gtk.Box {
  public AstalWp.Wp wp { get; construct set; }

  [GtkChild]
  private unowned Gtk.ListBox sinks;

  [GtkChild]
  private unowned Gtk.ListBox sources;

  [GtkChild]
  private unowned Gtk.ListBox mixers;

  [GtkChild]
  private unowned Gtk.Adjustment speaker_adjust;

  [GtkChild]
  private unowned Gtk.Adjustment mic_adjust;

  [GtkCallback]
  public void toggle_mute_speaker() {
    this.wp.audio.default_speaker.mute = !this.wp.audio.default_speaker.mute;
  }

  [GtkCallback]
  public void toggle_mute_mic() {
    this.wp.audio.default_microphone.mute = !this.wp.audio.default_microphone.mute;
  }

  private void on_added(AstalWp.Endpoint endpoint, Gtk.ListBox lb) {
    lb.append(new KompassBar.QsAudioEndpoint(endpoint));
  }

  private void on_removed(AstalWp.Endpoint endpoint, Gtk.ListBox lb) {
    int i = 0;

    KompassBar.QsAudioEndpoint? ep = (KompassBar.QsAudioEndpoint)lb.get_row_at_index(0);
    while (ep != null) {
      if (ep.endpoint == endpoint) {
        lb.remove(ep);
        break;
      }
      ep = (KompassBar.QsAudioEndpoint)lb.get_row_at_index(++i);
    }
  }

  construct {
    this.wp = AstalWp.get_default();

    this.wp.audio.default_speaker.bind_property("volume", speaker_adjust, "value",
                                                GLib.BindingFlags.BIDIRECTIONAL | GLib.BindingFlags.SYNC_CREATE);
    this.wp.audio.default_microphone.bind_property("volume", mic_adjust, "value",
                                                   GLib.BindingFlags.BIDIRECTIONAL | GLib.BindingFlags.SYNC_CREATE);

    this.wp.audio.speakers.@foreach(ep => this.on_added(ep, this.sinks));
    this.wp.audio.microphones.@foreach(ep => this.on_added(ep, this.sources));
    this.wp.audio.streams.@foreach(ep => this.on_added(ep, this.mixers));

    this.wp.audio.stream_added.connect((audio, endpoint) => this.on_added(endpoint, this.mixers));
    this.wp.audio.speaker_added.connect((audio, endpoint) => this.on_added(endpoint, this.sinks));
    this.wp.audio.microphone_added.connect((audio, endpoint) => this.on_added(endpoint, this.sources));

    this.wp.audio.stream_removed.connect((audio, endpoint) => this.on_removed(endpoint, this.mixers));
    this.wp.audio.speaker_removed.connect((audio, endpoint) => this.on_removed(endpoint, this.sinks));
    this.wp.audio.microphone_removed.connect((audio, endpoint) => this.on_removed(endpoint, this.sources));
  }
}
