[GtkTemplate (ui = "/com/github/kotontrion/kompass/ui/appButton.ui")]
public class Kompass.AppButton : Gtk.ListBoxRow {

    public AstalApps.Application app {get; construct;}
    public double score { get; set;}

    [GtkCallback]
    public void clicked() {
      app.launch();
    }

    public AppButton(AstalApps.Application app) {
        Object(app: app);
    }

}
