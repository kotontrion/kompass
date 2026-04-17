namespace Kompass {
public interface SearchResultView : Object {
  public abstract SearchProvider provider { get; construct; }

  public virtual async void search(string query) {
    this.provider.search.begin(query);
  }

  public virtual bool launch_first() {
    return this.provider.launch_first();
  }
}

[GtkTemplate(ui = "/com/github/kotontrion/libkompass/ui/search-result-view.ui")]
public class RevealingSearchResultView : Gtk.Box, SearchResultView {
  [GtkChild]
  private unowned Gtk.Revealer revealer;
  [GtkChild]
  private unowned Gtk.ListBox results;

  public SearchProvider provider { get; construct; }
  private uint _max_results = 5;
  public uint max_results {
    get { return this._max_results; }
    set {
      this._max_results = value;
      this.result_model.size = value;
    }
  }

  private Gtk.SliceListModel result_model;

  public void set_create_widget_fun(owned Gtk.ListBoxCreateWidgetFunc? widget_fun) {
    if (widget_fun != null) {
      this.results.bind_model(this.result_model, (owned)widget_fun);
    } else {
      this.results.bind_model(this.result_model, result_button_factory);
    }
  }

  private Gtk.Widget result_button_factory(Object item) {
    return new SearchResultButton(item as Kompass.SearchResult);
  }

  static construct {
    set_css_name("searchresultprovider");
  }

  public RevealingSearchResultView(SearchProvider provider) {
    Object(provider: provider);
  }

  construct {
    this.result_model = new Gtk.SliceListModel(this.provider.results, 0, this.max_results);
    this.results.bind_model(this.result_model, result_button_factory);
    result_model.items_changed.connect(() => {
        this.revealer.reveal_child = this.provider.results.get_n_items() > 0;
      });
    this.revealer.reveal_child = this.provider.results.get_n_items() > 0;
  }
}

public class Launcher : Gtk.Box, Gtk.Buildable {
  static construct {
    set_css_name("launcher");
  }

  construct {
    this.orientation = Gtk.Orientation.VERTICAL;
  }

  public async void search(string query) {
    for (var child = this.get_first_child(); child != null; child = child.get_next_sibling()) {
      if (child is SearchResultView && child != null) {
        ((SearchResultView)child).search.begin(query);
      }
    }
  }

  public void add_child(Gtk.Builder builder, Object child, string? type) {
    if (child is SearchProvider) {
      var provider = new RevealingSearchResultView(child as SearchProvider);
      base.add_child(builder, provider, type);
    } else {
      base.add_child(builder, child, type);
    }
  }

  public void launch_first() {
    for (var child = this.get_first_child(); child != null; child = child.get_next_sibling()) {
      if (child is SearchResultView) {
        if ((child as SearchResultView)?.launch_first()) {
          return;
        }
      }
    }
  }
}
}
