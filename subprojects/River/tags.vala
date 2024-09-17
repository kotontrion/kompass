namespace River {

class Tag : Astal.Button {

  public int index { get; construct; }
  public bool show_labels { get; construct; }
  private AstalRiver.Output output;

  construct {

    if(show_labels)
      this.label = (index+1).to_string();

    Astal.widget_set_class_names(this, {"tag"});

    this.clicked.connect(() => {
      string[] cmd = {"set-focused-tags", (1 << index).to_string()};
      river.run_command_async(cmd, null);
    });

    this.valign = Gtk.Align.CENTER;
    this.halign = Gtk.Align.CENTER;

    this.realize.connect(() => {
      output = this.getOutput();

        update_css();
        output.changed.connect(() => {
          update_css();
        });

      });
  }

  private void update_css() {
    uint occupied_tags = output.occupied_tags;
    uint focused_tags = output.focused_tags;

    Astal.widget_toggle_class_name(this, "occupied", (occupied_tags & (1 << index)) != 0);
    Astal.widget_toggle_class_name(this, "focused", (focused_tags & (1 << index)) != 0);

  }

  public Tag(int index, bool show_labels) {
    Object(index: index, show_labels: show_labels);
  }


  private AstalRiver.Output? getOutput() {
    Gdk.Display display = Gdk.Display.get_default();
    Gdk.Monitor gdkmonitor = display.get_monitor_at_window(this.get_window());
    Gdk.Screen screen = display.get_default_screen();
    for(int i = 0; i < display.get_n_monitors(); ++i) {
      if(gdkmonitor == display.get_monitor(i)) {
        string monitor_name = screen.get_monitor_plug_name(i);
        return river.get_output(monitor_name);
      }
    }
    return null;
  }



}

class Tags : Astal.Box {

  public int num_tags { get; construct; default=9; }
  public bool show_labels { get; construct; default=true; }

  construct {
    for (int i = 0; i < this.num_tags; i++) {
      Tag tag = new Tag(i, show_labels);
      this.add(tag);
    }
    
    Astal.widget_set_class_names(this, {"tags"});
    
  
    this.show_all();
  }
  
  public Tags(bool vertical, List children) {
    base(vertical, children);
  }

}
}

