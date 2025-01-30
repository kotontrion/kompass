namespace Kompass {
private class Tag : Gtk.Box {
  public int index { get; construct; }
  public AstalRiver.Output output { get; construct; }

  private Gtk.Label label;
  public RiverTags tags { get; construct; }
  private Gtk.GestureClick lc;
  private Gtk.GestureClick rc;


  construct {
    valign = Gtk.Align.CENTER;
    halign = Gtk.Align.CENTER;

    label = new Gtk.Label(@"$(index + 1)");
  
    tags.bind_property("show_numbers", label, "visible", GLib.BindingFlags.SYNC_CREATE);
    this.append(label);

    lc = new Gtk.GestureClick();
    lc.set_button(Gdk.BUTTON_PRIMARY);
    lc.pressed.connect(() => output.focused_tags = 1 << index);
    this.add_controller(lc);

    rc = new Gtk.GestureClick();
    rc.set_button(Gdk.BUTTON_SECONDARY);
    rc.pressed.connect(() => output.focused_tags ^= 1 << index);
    this.add_controller(rc);

    output.changed.connect(update_css);

    update_css();
  }

  private void update_css() {
    uint occupied_tags = output.occupied_tags;
    uint focused_tags = output.focused_tags;
    uint urgent_tags = output.urgent_tags;

    if ((occupied_tags & (1 << index)) != 0) {
      add_css_class("occupied");
    } else {
      remove_css_class("occupied");
    }

    if ((focused_tags & (1 << index)) != 0) {
      add_css_class("focused");
    } else {
      remove_css_class("focused");
    }

    if ((urgent_tags & (1 << index)) != 0) {
      add_css_class("urgent");
    } else {
      remove_css_class("urgent");
    }

  }

  public Tag(int index, AstalRiver.Output output, RiverTags tags) {
    Object(index: index, output: output, tags: tags, css_name: "tag");
  }
}

public class RiverTags : Gtk.Box {
  public AstalRiver.Output output { get; set; }
  public bool show_numbers { get; set; default = false; }
  public uint tags { get; set; default = 9; }

  construct {
    this.notify["output"].connect(() => recreate_children());
    this.notify["tags"].connect(() => recreate_children());
  }

  private void recreate_children() {
    var child = this.get_first_child();
      while (child != null) {
        this.remove(child);
        child = this.get_first_child();
      }

      if (output == null) {
        this.visible = false;
        return;
      }
      this.visible = true;
      for (int i = 0; i < tags; i++) {
        append(new Tag(i, output, this));
      }
  }
}
}
