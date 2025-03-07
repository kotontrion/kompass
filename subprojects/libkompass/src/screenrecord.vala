namespace Kompass {

public class ScreenRecorder : Object {
  private static ScreenRecorder instance;
  public static ScreenRecorder get_default() {
    if (instance == null) {
      instance = new ScreenRecorder();
    }
    return instance;
  }

  private Xdp.Portal portal;

  private AstalIO.Process recorder;

  public bool recording { get; private set; }

  construct {
    this.portal = new Xdp.Portal();
    this.recording = false;
  }

  public async string? take_screenshot(string? filepath) {
    string path = filepath;
    if (path == null || path == "") {
      string picture_dir = Environment.get_user_special_dir(UserDirectory.PICTURES);
      string file_name = new DateTime.now_local().format_iso8601();
      path = "%s/Screenshots/%s.png".printf(picture_dir, file_name);
    }
    File destination = GLib.File.new_for_path(path);
    try {
      string uri = yield portal.take_screenshot(
        null,
        Xdp.ScreenshotFlags.INTERACTIVE,
        null
        );

      File source = GLib.File.new_for_uri(uri);
      source.copy(destination, FileCopyFlags.NONE, null, null);
      return destination.get_path();
    } catch (Error e) {
      critical(e.message);
      return null;
    }
  }

  public void start_record(string? file_path) {
    //TODO: use portal and gstreamer instead of wf-recorder
    if (this.recording) {
      return;
    }
    string path = file_path;
    if (path == null || path == "") {
      string video_dir = Environment.get_user_special_dir(UserDirectory.VIDEOS);
      string file_name = new DateTime.now_local().format_iso8601();
      path = "%s/Screencasting/%s.mp4".printf(video_dir, file_name);
    }

    AstalIO.Process.exec_async.begin("slurp", (obj, res) => {
        string geometry = AstalIO.Process.exec_async.end(res);

        string cmd = "bash -c 'wf-recorder -g \"%s\" --pixel-format yuv420p -f %s'"
                       .printf(geometry, path);
        try {
          this.recorder = AstalIO.Process.subprocess(cmd);
          this.recording = true;
        } catch (Error e) {
          critical("%s\n", e.message);
        }
      });
  }

  public void stop_record() {
    if (!this.recording) {
      return;
    }
    this.recorder.signal(15);
    this.recorder = null;
    this.recording = false;
  }
}
}
