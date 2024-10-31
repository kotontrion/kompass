[DBus (name="io.Astal.Application")]
public class Kompass.Application : Adw.Application, AstalIO.Application {
    
    private SocketService service;
    private DBusConnection conn;
    private string socket_path { get; private set; }

    [DBus (visible=false)]
    public string instance_name {owned get; construct set;}

    construct {
        instance_name = "kompass";
        try {
            acquire_socket();
        }
        catch (Error e) {
           printerr("%s", e.message);
        }
        shutdown.connect(() => { try { quit(); } catch(Error err) {} });
        Unix.signal_add(1, () => { try { quit(); } catch(Error err) {} }, Priority.HIGH);
        Unix.signal_add(2, () => { try { quit(); } catch(Error err) {} }, Priority.HIGH);
        Unix.signal_add(15, () => { try { quit(); } catch(Error err) {} }, Priority.HIGH);
    }

    public Application () {
        Object (
            application_id: "io.Astal.kompass",
            flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    [DBus (visible=false)]
    public void inspector() throws DBusError, IOError {
        Gtk.Window.set_interactive_debugging(true);
    }

    [DBus (visible=false)]
    public void acquire_socket() throws Error {
        string path;
        service = AstalIO.acquire_socket(this, out path);
        socket_path = path;

        Bus.own_name(
            BusType.SESSION,
            application_id,
            BusNameOwnerFlags.NONE,
            (conn) => {
                try {
                    this.conn = conn;
                    conn.register_object("/io/Astal/Application", this);
                } catch (Error err) {
                    critical(err.message);
                }
            },
            () => {},
            () => {}
        );
    }
    
    [DBus (visible=false)]
    public Gtk.Window? get_window(string name) {
        foreach(var win in get_windows()) {
            if (win.name == name)
                return win;
        }

        critical("no window with name \"%s\"".printf(name));
        return null;
    }

    public void toggle_window(string window) throws Error {
        var win = get_window(window);
        if (win != null) {
            win.visible = !win.visible;
        } else {
            throw new IOError.FAILED("window not found");
        }
    }
    
    [DBus (visible=false)]
    public virtual void request(string msg, SocketConnection conn) throws Error {
        AstalIO.write_sock.begin(conn, @"missing response implementation on $instance_name");
    }


    public new void quit() throws DBusError, IOError {
        if (service != null) {
            service.stop();
            service.close();
        }
        base.quit();
    }

    [DBus (visible=false)]
    public override void activate () {
        base.activate ();


        Gtk.IconTheme icon_theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default());
        icon_theme.add_resource_path("/com/github/kotontrion/kompass/icons/");

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
        this.hold();
    }
}
