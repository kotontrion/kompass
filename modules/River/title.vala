
namespace River{

class Title : Astal.Label {

  private AstalRiver.River river;

  construct {
    this.river = AstalRiver.get_default();
    this.label = river.focused_view;
    this.river.notify["focused-view"].connect(() => {
      this.label = river.focused_view;
    });
  }

}
}

public void init() {
}

public void deinit() {
}
