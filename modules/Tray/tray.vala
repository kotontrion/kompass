
namespace KompassTray {

class TrayItem : Gtk.Button {

  private AstalTray.TrayItem item;
  private Astal.Icon icon;
  private Gtk.Menu? menu;

  public TrayItem(AstalTray.TrayItem item) {
    this.item = item;

    Astal.widget_set_class_names(this, {"tray-item"});

    this.icon = new Astal.Icon();
    this.icon.g_icon = this.item.gicon;
    this.item.notify["gicon"].connect(() => {
      this.icon.g_icon = this.item.gicon;
    });
    
    this.add(icon);
    this.tooltip_markup = this.item.tooltip_markup;

    this.menu = this.item.create_menu();
    this.show_all();

    this.clicked.connect(() => {
      menu.popup_at_widget (this, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH, null);
    });

  }

}

class Tray : Astal.Box {

  private HashTable<string, TrayItem> items;

  construct {
    this.items = new HashTable<string, TrayItem>(GLib.str_hash, GLib.str_equal);

    Astal.widget_set_class_names(this, {"tray"});
    
    KompassTray.tray.item_added.connect(id => {
      if(this.items.contains(id)) return;
      AstalTray.TrayItem item = KompassTray.tray.get_item(id);
      if(item == null) return;
      TrayItem tray_item = new TrayItem(item);
      this.items.insert (id, tray_item);
      this.add(tray_item);
    });
    
    KompassTray.tray.item_removed.connect(id => {
      if(!this.items.contains(id)) return;
      TrayItem item = this.items.get(id);
      if(item == null) return;
      this.items.remove (id);
      this.remove(item);

    });

  }

  public Tray(bool vertical, List<weak Gtk.Widget> children) {
    base(vertical, children);
  }

}
}

