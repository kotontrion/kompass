namespace Kompass {
public class IconUtils {
  public static uint wifi_icon_to_state(string icon_name) {
    switch (icon_name) {
      case ("network-wireless-signal-excellent-symbolic"):
      case ("network-wireless-signal-good-symbolic"):
        return 3;

      case ("network-wireless-signal-ok-symbolic"):
        return 2;

      case ("network-wireless-signal-weak-symbolic"):
        return 1;

      case ("network-wireless-signal-none-symbolic"):
        return 0;

      case ("network-wireless-acquiring-symbolic"):
        return 4;

      case ("network-wireless-offline-symbolic"):
        return 5;

      case ("network-wireless-disabled-symbolic"):
        return 6;

      case ("network-wireless-connected-symbolic"):
      case ("network-wireless-no-route-symbolic"):
      case ("network-wireless-hotspot-symbolic"):
      default:
        return 0;
    }
  }

  public static uint volume_to_state(double volume, bool mute) {
    if (mute) {
      return 6;
    }
    int state = (int)(volume * 4) + 1;
    if (state > 5) {
      state = 5;
    }
    return state;
  }
}
}
