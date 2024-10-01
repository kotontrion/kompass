public class Kompass.Application : Adw.Application {
    public Application () {
        Object (
            application_id: "com.github.kotontrion.kompass",
            flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }


    public override void activate () {
        base.activate ();

        Gtk.CssProvider provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/kotontrion/kompass/style.css");
        Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default (), provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        AstalRiver.River river = AstalRiver.get_default();

        river.output_added.connect((riv, name) => {
            Gdk.Display.get_default().sync();
            var win = new Kompass.Bar (this, river.get_output(name));
            win.present ();
        });

        foreach(AstalRiver.Output output in river.get_outputs()) {
            var win = new Kompass.Bar (this, output);
            win.present ();
        }

    }
}
