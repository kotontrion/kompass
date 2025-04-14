[GtkTemplate(ui = "/com/github/kotontrion/libkompass/ui/search-result-button.ui")]
public class Kompass.SearchResultButton : Gtk.ListBoxRow {
  public Kompass.SearchResult result { get; set; }

  [GtkCallback]
  public void clicked() {
    result.activate();
  }

  [GtkCallback]
  public void activated() {
    result.activate();
  }

  public SearchResultButton(Kompass.SearchResult result) {
    Object(result: result);
  }
}
