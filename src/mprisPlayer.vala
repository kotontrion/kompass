
[GtkTemplate (ui = "/com/github/kotontrion/kompass/ui/mprisPlayer.ui")]
public class Kompass.Player : Gtk.Box {

    public AstalMpris.Player player {get; set;}
    private Gtk.CssProvider css_prov;

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
      //string style = "* { background-image: url(" + this.player.art_url + "); }";
      string style = "* { background-image: linear-gradient(rgba(0, 0, 0, 0), " +
              "alpha(@view_bg_color, 0.9))," +
              "url(\"" + this.player.art_url +"\"); }";

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

        player.notify["art-url"].connect(() => {
          update_background();
        });
        update_background();
    }
}
