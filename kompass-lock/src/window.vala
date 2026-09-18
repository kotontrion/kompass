namespace KompassLock {
public class Window : Gtk.Window {

  public Window(Gdk.Monitor monitor) {
    Object(
      application: (KompassLock.Application)GLib.Application.get_default(),
      title: "Kompass Lock"
    );

    var lockscreen = new KompassLock.Lockscreen(this.application as KompassLock.Application);
    child = lockscreen;
  }
}
}
