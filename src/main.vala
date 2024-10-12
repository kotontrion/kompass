
void ensure_types() {
    //Types referenced in blueprint have to be ensured
    typeof(Kompass.Tags).ensure();
    typeof(Kompass.Clock).ensure();
    typeof(Kompass.Qs).ensure();
    typeof(Kompass.QsAudio).ensure();
    typeof(Kompass.QsBluetooth).ensure();
    typeof(Kompass.QsButton).ensure();
    typeof(Kompass.QsNotif).ensure();
    typeof(Kompass.Cava).ensure();
    typeof(Kompass.Launcher).ensure();
    typeof(Kompass.AppButton).ensure();
}

int main (string[] args) {

    ensure_types();

    var app = new Kompass.Application ();
    return app.run (args);
}
