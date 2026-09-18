using Gtk;

namespace KompassLock {
public class Application : Adw.Application {
  private GtkSessionLock.Instance session_lock;
  private AstalAuth.Pam pam;
  private bool authenticating = false;
  private bool prompt_pending = false;
  private GLib.List<Window> windows;

  public string auth_message { get; private set; default = ""; }
  public bool auth_prompt_secret { get; private set; default = false; }
  public bool auth_prompt_visible { get; private set; default = false; }
  public bool auth_prompt_visible_response { get; private set; default = false; }
  public bool auth_input_enabled { get; private set; default = true; }

  public Application() {
    Object(
      application_id: "net.kotontrion.kompass.lock",
      flags: ApplicationFlags.DEFAULT_FLAGS
    );

    pam = (AstalAuth.Pam)Object.new(typeof(AstalAuth.Pam));
    pam.auth_prompt_visible.connect((message) => {
      prompt_pending = true;
      auth_message = message;
      auth_prompt_secret = false;
      auth_prompt_visible = true;
      auth_prompt_visible_response = true;
      auth_input_enabled = true;
    });
    pam.auth_prompt_hidden.connect((message) => {
      prompt_pending = true;
      auth_message = message;
      auth_prompt_secret = true;
      auth_prompt_visible = true;
      auth_prompt_visible_response = false;
      auth_input_enabled = true;
    });
    pam.auth_info.connect((message) => {
      auth_message = message;
      auth_prompt_visible = false;
      auth_prompt_visible_response = false;
      pam.supply_secret(null);
    });
    pam.auth_error.connect((message) => {
      auth_message = message;
      auth_prompt_visible = false;
      auth_prompt_visible_response = false;
      pam.supply_secret(null);
    });
    pam.success.connect(() => {
      authenticating = false;
      prompt_pending = false;
      this.unlock();
    });
    pam.fail.connect((message) => {
      authenticating = false;
      prompt_pending = false;
      auth_message = message;
      auth_prompt_visible = false;
      auth_prompt_visible_response = false;
      auth_input_enabled = true;
    });
  }

  public override void activate() {
    if (session_lock != null) {
      return;
    }

    windows = new GLib.List<Window>();
    if (!GtkSessionLock.is_supported()) {
      warning("The compositor does not support the Wayland session-lock protocol\n");
      quit();
      return;
    }

    session_lock = new GtkSessionLock.Instance();
    session_lock.monitor.connect((monitor) => assign_window(monitor));
    session_lock.failed.connect(() => {
      warning("Could not acquire the session lock\n");
      quit();
    });
    session_lock.unlocked.connect(() => {
      quit();
    });

    if (!session_lock.lock()) {
      quit();
    }
  }

  private void assign_window(Gdk.Monitor monitor) {
    var window = new Window(monitor);
    windows.append(window);
    session_lock.assign_window_to_monitor(window, monitor);
  }

  public void unlock() {
    if (session_lock != null && session_lock.is_locked()) {
      session_lock.unlock();
    }
  }

  public void authenticate() {
    if (authenticating) {
      return;
    }

    authenticating = true;
    auth_message = _("Checking credentials…");
    auth_input_enabled = false;
    if (!pam.start_authenticate()) {
      authenticating = false;
      auth_message = _("Authentication is unavailable");
      auth_input_enabled = true;
    }
  }

  public void submit_response(string response) {
    if (!authenticating || !prompt_pending) {
      return;
    }

    prompt_pending = false;
    auth_input_enabled = false;
    pam.supply_secret(response);
  }

  public override void shutdown() {
    this.unlock();
    base.shutdown();
  }
}
}
