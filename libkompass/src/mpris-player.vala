[GtkTemplate(ui = "/com/github/kotontrion/libkompass/ui/mpris-player.ui")]
public class Kompass.Player : Gtk.Box {
  public AstalMpris.Player player { get; set; }

  public File cover_file { get; private set; }
  public string empty_cover_uri { get; set; default = "resource:///com/github/kotontrion/libkompass/images/empty-mpris-image.png"; }

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
  public void raise() {
    this.player.raise();
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

  private void update_cover() {
    if (this.player.cover_art != null && this.player.cover_art != "") {
      File file = File.new_for_path(this.player.cover_art);
      if (file.query_exists(null)) {
        this.cover_file = file;
        return;
      }
    }
    this.cover_file = File.new_for_uri(this.empty_cover_uri);
  }

  public Player(AstalMpris.Player player) {
    Object(player: player);

    player.notify["cover-art"].connect(() => {
      update_cover();
    });
    update_cover();
  }
}
