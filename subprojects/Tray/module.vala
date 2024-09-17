namespace KompassTray {
  protected AstalTray.Tray tray;
}

public void init() {
  KompassTray.tray = AstalTray.get_default();
}
