private class Kompass.Tag : Gtk.Button {

    public int index { get; construct; }
    public AstalRiver.Output output { get; construct; }

    construct {

        valign = Gtk.Align.CENTER;
        halign = Gtk.Align.CENTER;

        this.clicked.connect(() => {
            output.focused_tags = 1 << index;
        });
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

    AstalRiver.Output output { get; private set; }

    construct {
        this.realize.connect(() => {
            output = ((Kompass.Bar)get_root()).output;

            for( int i = 0; i < 9; i++ ) {
                append(new Tag(i, output));
            }
        });
    }
}
