{
  inputs = {
    astal = {
      type = "github";
      owner = "Aylur";
      repo = "astal";
    };

    nixpkgs.follows = "astal/nixpkgs";

    systems = {
      type = "github";
      owner = "nix-systems";
      repo = "default-linux";
    };
  };

  outputs = {
    self,
    systems,
    nixpkgs,
    astal,
    ...
  }: let
    perSystem = attrs:
      nixpkgs.lib.genAttrs (import systems) (system:
        attrs (import nixpkgs {inherit system;}));

    inherit (nixpkgs.lib) attrValues elemAt getExe head match readFile splitString;
    getMesonValue = val: file:
      head (match "^([^']*).*" (elemAt (splitString val (readFile file)) 1));
  in {
    packages = perSystem (pkgs: {
      libkompass = pkgs.callPackage (
        {
          stdenv,
          lib,
          ...
        }: let
          pname = "libkompass";
          version = getMesonValue "version: '" "${self}/subprojects/libkompass/meson.build";

          apiVersion = getMesonValue "api_version = '" "${self}/subprojects/libkompass/src/meson.build";
        in
          stdenv.mkDerivation {
            inherit pname version;

            src = self;
            sourceRoot = "source/subprojects/libkompass";

            postPatch = ''
              substituteInPlace ./src/screenrecord.vala \
                  --replace-fail "slurp" "${getExe pkgs.slurp}" \
                  --replace-fail "bash -c 'wf-recorder" "${getExe pkgs.bash} -c '${getExe pkgs.wf-recorder}"
            '';

            nativeBuildInputs = attrValues {
              # Build Dependencies as declared in src/meson.build
              inherit
                (pkgs)
                libadwaita # libadwaita-1
                wrapGAppsHook4 # gio-2.0
                libportal # libportal
                ;
              inherit
                (astal.packages.${pkgs.system})
                apps # astal-apps-0.1
                bluetooth # astal-bluetooth-0.1
                io # astal-io-0.1
                cava # astal-cava-0.1
                mpris # astal-mpris-0.1
                notifd # astal-notifd-0.1
                tray # astal-tray-0.1
                river # astal-river-0.1
                wireplumber # astal-wireplumber-0.1
                ;

              # Build Dependencies as declared in data/ui/meson.build
              inherit
                (pkgs)
                blueprint-compiler # blueprint-compiler
                ;

              # Build Dependencies as declared in data/scss/meson.build
              inherit
                (pkgs)
                dart-sass # sass
                ;

              # Build tools
              inherit
                (pkgs)
                gawk # awk
                gobject-introspection # g-ir-compiler
                libxml2 # xmllint
                meson
                ninja
                pkg-config
                vala
                ;
            };

            passthru.girName = "Kompass-0.1";

            meta = {
              license = lib.licenses.lgpl3Only;
            };
          }
      ) {};

      docs = pkgs.callPackage ({
        stdenv,
        lib,
        gobject-introspection,
        gi-docgen,
        ...
      }: let
        pname = "libkompass";
        libkompass = self.packages.${pkgs.system}.libkompass;
        version = libkompass.version;
        girFile = "${libkompass}/share/gir-1.0/${libkompass.passthru.girName}.gir";
        data = (pkgs.formats.toml {}).generate "libkompass" {
          library = {
            description = "A collection of widgets useful for creating status bars using astal.";
            authors = "kotontrion";
            version = libkompass.version;
            license = "LGPL-3-0";
            browse_url = "https://github.com/kotontrion/kompass/tree/main/subprojects/libkompass";
            repository_url = "https://github.com/kotontrion/kompass.git";
          };
          extra.urlmap_file = "urlmap.js";
        };
        docgen = pkgs.gi-docgen.overrideAttrs {
          patches = [./gi-docgen.patch];
        };
        urlmap = pkgs.writeText "urlmap" ''
          baseURLs = ${builtins.toJSON [
            ["GLib" "https://docs.gtk.org/glib/"]
            ["GObject" "https://docs.gtk.org/gobject/"]
            ["Gio" "https://docs.gtk.org/gio/"]
            ["Gdk" "https://docs.gtk.org/gdk4/"]
            ["Gtk" "https://docs.gtk.org/gtk4/"]
            ["GdkPixbuf" "https://docs.gtk.org/gdk-pixbuf/"]
            ["Adw" "https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1-latest/"]
            ["AstalIO" "https://aylur.github.io/libastal/io/"]
            ["AstalNotifd" "https://aylur.github.io/libastal/notifd/"]
            ["AstalBluetooth" "https://aylur.github.io/libastal/bluetooth/"]
            ["AstalCava" "https://aylur.github.io/libastal/cava/"]
            ["AstalMpris" "https://aylur.github.io/libastal/mpris/"]
            ["AstalRiver" "https://aylur.github.io/libastal/river/"]
            ["AstalWp" "https://aylur.github.io/libastal/wireplumber/"]
            ["AstalApps" "https://aylur.github.io/libastal/apps/"]
            ["AstalNetwork" "https://aylur.github.io/libastal/network/"]
            ["AstalTray" "https://aylur.github.io/libastal/tray/"]
          ]}
        '';
      in
        stdenv.mkDerivation {
          inherit pname version;
          src = self;
          sourceRoot = "source/subprojects/libkompass";
          nativeBuildInputs = [
            gobject-introspection
            gi-docgen
          ];
          buildInputs = attrValues {
              # Build Dependencies as declared in src/meson.build
              inherit
                (pkgs)
                libadwaita # libadwaita-1
                ;
              inherit
                (astal.packages.${pkgs.system})
                apps # astal-apps-0.1
                bluetooth # astal-bluetooth-0.1
                io # astal-io-0.1
                cava # astal-cava-0.1
                mpris # astal-mpris-0.1
                notifd # astal-notifd-0.1
                tray # astal-tray-0.1
                river # astal-river-0.1
                wireplumber # astal-wireplumber-0.1
                ;
            };
          buildPhase = ''
            cat ${urlmap} > urlmap.js
            ${docgen}/bin/gi-docgen generate --config=${data} ${girFile}
          '';
          installPhase = ''        
            mkdir -p $out/share/doc/${pname}
            mv ${libkompass.passthru.girName}/* $out/share/doc/${pname}
          '';
          meta = {
            description = "Documentation for libkompass";
            license = lib.licenses.lgpl3Only;
          };
        }) {};

      kompass = pkgs.callPackage (
        {
          stdenv,
          lib,
          ...
        }: let
          pname = "kompass";
          version = getMesonValue "version: '" "${self}/subprojects/kompass/meson.build";
        in
          stdenv.mkDerivation {
            inherit pname version;

            src = self;
            sourceRoot = "source/subprojects/kompass";

            nativeBuildInputs = attrValues {
              # Build Dependencies as declared in src/meson.build
              inherit
                (self.packages.${pkgs.system})
                libkompass # kompass-0.1
                ;
              inherit
                (pkgs)
                wrapGAppsHook4 # gio-2.0
                gtk4 # gtk4
                gtk4-layer-shell # gtk4-layer-shell-0
                libadwaita # libadwaita-1
                networkmanager # libnm
                ;
              inherit
                (astal.packages.${pkgs.system})
                astal4 # astal-4-4.0
                io # astal-io-0.1
                mpris # astal-mpris-0.1
                river # astal-river-0.1
                battery # astal-battery-0.1
                bluetooth # astal-bluetooth-0.1
                network # astal-network-0.1
                notifd # astal-notifd-0.1
                apps # astal-apps-0.1
                wireplumber # astal-wireplumber-0.1
                ;

              # Build Dependencies as declared in data/ui/meson.build
              inherit
                (pkgs)
                blueprint-compiler # blueprint-compiler
                ;

              # Build Dependencies as declared in data/scss/meson.build
              inherit
                (pkgs)
                dart-sass # sass
                ;

              # Build tools
              inherit
                (pkgs)
                gawk # awk
                libxml2 # xmllint
                gobject-introspection # for typelibs
                meson
                ninja
                pkg-config
                vala
                ;
            };

            meta = {
              license = lib.licenses.gpl3Only;
            };
          }
      ) {};

      default = self.packages.${pkgs.system}.kompass;
    });

    devShells = perSystem (pkgs: {
      default = pkgs.mkShell {
        nativeBuildInputs = with self.packages.${pkgs.system}; (libkompass.nativeBuildInputs ++ kompass.nativeBuildInputs);
        inputsFrom = attrValues {
          inherit
            (self.packages.${pkgs.system})
            libkompass
            kompass
            ;
        };
      };
    });

    formatter = perSystem (pkgs: pkgs.alejandra);
  };
}
