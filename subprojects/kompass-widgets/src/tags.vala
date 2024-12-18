private class Kompass.Tag : Gtk.Box {

    public int index { get; construct; }
    public AstalRiver.Output output { get; construct; }
    private Gtk.GestureClick lc;
    private Gtk.GestureClick rc;

    construct {

        valign = Gtk.Align.CENTER;
        halign = Gtk.Align.CENTER;

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

        if((occupied_tags & (1 << index)) != 0)
            add_css_class("occupied");
        else
            remove_css_class("occupied");

        if((focused_tags & (1 << index)) != 0)
            add_css_class("focused");
        else
            remove_css_class("focused");
    }

    public Tag(int index, AstalRiver.Output output) {
        Object(index: index, output: output, css_name: "tag");
    }
}

public class Kompass.Tags : Gtk.Box {

    public AstalRiver.Output output { get; set; }

    construct {
        this.notify["output"].connect(() => {
           
            var child = this.get_first_child();
            while(child != null) {
              this.remove(child);
              child = this.get_first_child();
            }
            
            if(output == null) return;

            for( int i = 0; i < 9; i++ ) {
                append(new Tag(i, output));
            }
        });
    }
}
