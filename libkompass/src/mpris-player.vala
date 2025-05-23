[GtkTemplate(ui = "/com/github/kotontrion/libkompass/ui/mpris-player.ui")]
public class Kompass.Player : Gtk.Box {
  public AstalMpris.Player player { get; set; }
  private Gtk.CssProvider css_prov;

  public File cover_file { get; private set; }

  [GtkCallback]
  public void next() {
    this.player.next();
  }

  [GtkCallback]
  public void prev() {
    this.player.previous();
  }

  [GtkCallback]
  public void play_pause() {
    this.player.play_pause();
  }

  [GtkCallback]
  public string pause_icon(AstalMpris.PlaybackStatus status) {
    switch (status) {
      case AstalMpris.PlaybackStatus.PLAYING:
        return "media-playback-pause-symbolic";

      case AstalMpris.PlaybackStatus.PAUSED:
      case AstalMpris.PlaybackStatus.STOPPED:
      default:
        return "media-playback-start-symbolic";
    }
  }

  private void update_background() {
    string url = this.player.art_url != null && this.player.art_url != ""
                 ? "url(\"" + this.player.art_url + "\")"
                 : "-gtk-icontheme(\"" + this.player.entry + "\")";
    string style = "* { --cover: " + url + "; }";

    try {
      this.css_prov.load_from_string(style);
    } catch (Error err) {
      warning(err.message);
    }
  }

  public Player(AstalMpris.Player player) {
    Object(player: player);

    this.css_prov = new Gtk.CssProvider();
    this.get_style_context()
      .add_provider(this.css_prov, Gtk.STYLE_PROVIDER_PRIORITY_USER);

    player.notify["cover-art"].connect(() => {
      // update_background();
      this.cover_file = File.new_for_path(this.player.cover_art);
    });
    this.cover_file = File.new_for_path(this.player.cover_art);
    // update_background();
  }
}
