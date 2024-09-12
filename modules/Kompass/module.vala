namespace Kompass {

  protected AstalBattery.Device battery;
  protected AstalBluetooth.Bluetooth bluetooth;
  protected AstalNetwork.Network network;

}

public void init() {
  Kompass.battery = AstalBattery.get_default();
  Kompass.bluetooth = AstalBluetooth.get_default();
  Kompass.network = AstalNetwork.get_default();
}
