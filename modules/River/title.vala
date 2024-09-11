
namespace River {

class Title : Astal.Label {

  construct {
    this.label = river.focused_view;
    river.notify["focused-view"].connect(() => {
      this.label = river.focused_view;
    });
  }
}
}

