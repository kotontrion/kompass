namespace Kompass {
private class TrayItem : Gtk.Button {
  public AstalTray.TrayItem item { get; construct; }

  private Gtk.PopoverMenu menu;
  private Gtk.Image icon;

  private Gtk.GestureClick lc;
  private Gtk.GestureClick rc;

  public TrayItem(AstalTray.TrayItem item) {
    Object(item: item);
  }

  static construct {
    set_css_name("tray-item");
  }

  construct {
    icon = new Gtk.Image();
    item.bind_property("gicon", icon, "gicon", BindingFlags.SYNC_CREATE);
    this.set_child(icon);

    menu = new Gtk.PopoverMenu.from_model(item.menu_model);
    menu.set_parent(this);

    menu.set_position(Gtk.PositionType.RIGHT);

    item.notify["menu-model"].connect(() => {
        menu.menu_model = item.menu_model;
      });

    item.notify["action-group"].connect(() => {
        this.insert_action_group("dbusmenu", item.action_group);
      });
    this.insert_action_group("dbusmenu", item.action_group);

    lc = new Gtk.GestureClick();
    lc.set_button(Gdk.BUTTON_PRIMARY);
    lc.pressed.connect(() => {
        item.activate(0, 0);
      });
    this.add_controller(lc);

    rc = new Gtk.GestureClick();
    rc.set_button(Gdk.BUTTON_SECONDARY);
    rc.pressed.connect(() => {
        this.open_menu();
      });
    this.add_controller(rc);
  }

  public void open_menu() {
    if (this.item.menu_model != null) {
      item.about_to_show();
      menu.popup();
    }
  }

  ~TrayItem() {
    menu.unparent();
  }
}

public class Tray : Gtk.Box {
  private AstalTray.Tray tray = AstalTray.get_default();
  private HashTable<string, Gtk.Widget> items;

  construct {
    this.visible = false;
    this.items = new HashTable<string, Gtk.Widget>(str_hash, str_equal);

    this.tray.items.foreach((item) => {
        var tray_item = new Kompass.TrayItem(item);
        this.items.insert(item.item_id, tray_item);
        this.append(tray_item);
        this.visible = true;
      });

    this.tray.item_added.connect((obj, item_id) => {
        if (this.items.contains(item_id)) {
          return;
        }
        var item = new Kompass.TrayItem(tray.get_item(item_id));
        this.items.insert(item_id, item);
        this.append(item);
        this.visible = true;
      });
    this.tray.item_removed.connect((obj, item_id) => {
        if (!this.items.contains(item_id)) {
          return;
        }
        var item = this.items.take(item_id);
        this.remove(item);
        this.visible = items.size() > 0;
      });
  }
}
}
