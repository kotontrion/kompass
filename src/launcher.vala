[GtkTemplate (ui = "/com/github/kotontrion/kompass/ui/launcher.ui")]
public class Kompass.Launcher : Gtk.Box {

    public AstalApps.Apps apps {get; construct set;}

    [GtkChild]
    private unowned Gtk.Popover popover;
    
    [GtkChild]
    private unowned Gtk.ListBox app_list;
    
    [GtkChild]
    private unowned Gtk.Entry entry;

    [GtkCallback]
    public void open_launcher() {
      this.entry.text = "";
      this.popover.popup();
    }

    private int sort_func(Gtk.ListBoxRow la, Gtk.ListBoxRow lb) {
      AppButton a = (AppButton) la;
      AppButton b = (AppButton) lb;
      if(a.score == b.score) return b.app.frequency - a.app.frequency;
      return (int)((b.score - a.score)*100);
    }

    [GtkCallback]
    public void update_list() {
      int i = 0;
      Kompass.AppButton? app = (Kompass.AppButton) this.app_list.get_row_at_index(0);
      while(app != null) {
        app.score = app.app.fuzzy_match(this.entry.text).name;
        app = (Kompass.AppButton) this.app_list.get_row_at_index(++i);
      }
      this.app_list.invalidate_sort();
    }

    construct {
      this.apps = new AstalApps.Apps();

      this.app_list.set_sort_func(sort_func);

      this.apps.list.@foreach(app => {
        this.app_list.append(new AppButton(app));  
      });
    }

}
