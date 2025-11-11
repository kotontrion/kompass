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
    nixpkgs,
    astal,
    systems,
    ...
  }: let
    inherit (nixpkgs.lib) attrValues elemAt getExe head match readFile splitString;

    perSystem = attrs:
      nixpkgs.lib.genAttrs (import systems) (system:
        attrs (import nixpkgs {inherit system;}));

    getMesonValue = val: file:
      head (match "^([^']*).*" (elemAt (splitString val (readFile file)) 1));
  in {
    packages = perSystem (pkgs: {
      libkompass = pkgs.stdenv.mkDerivation {
        pname = "libkompass";
        version = getMesonValue "version: '" "${self}/meson.build";
        apiVersion = getMesonValue "api_version = '" "${self}/libkompass/meson.build";
        src = ./.;

        mesonFlags = [
          "-Dbuild_target=libkompass"
        ];

        postPatch = ''
          substituteInPlace ./libkompass/src/screenrecord.vala \
              --replace-fail "slurp" "${getExe pkgs.slurp}" \
              --replace-fail "bash -c 'wf-recorder" "${getExe pkgs.bash} -c '${getExe pkgs.wf-recorder}"
        '';

        nativeBuildInputs = attrValues {
          inherit
            (pkgs)
            meson
            ninja
            pkg-config
            wrapGAppsHook4
            vala
            gobject-introspection
            blueprint-compiler
            dart-sass
            gawk
            libxml2
            libnma-gtk4
            ;
        };

        buildInputs = attrValues {
          inherit
            (astal.packages.${pkgs.stdenv.hostPlatform.system})
            io
            apps
            battery
            bluetooth
            cava
            mpris
            network
            notifd
            river
            tray
            wireplumber
            ;

          inherit
            (pkgs)
            libadwaita
            libportal
            gtk4
            ;
        };

        passthru.girName = "Kompass-${self.packages.${pkgs.stdenv.hostPlatform.system}.libkompass.apiVersion}";
      };

      kompass = pkgs.stdenv.mkDerivation {
        pname = "kompass";
        version = getMesonValue "version: '" "${self}/meson.build";
        src = ./.;

        mesonFlags = [
          "-Dbuild_target=kompass"
        ];

        postPatch = ''
          substituteInPlace ./libkompass/src/screenrecord.vala \
              --replace-fail "slurp" "${getExe pkgs.slurp}" \
              --replace-fail "bash -c 'wf-recorder" "${getExe pkgs.bash} -c '${getExe pkgs.wf-recorder}"
        '';

        nativeBuildInputs = attrValues {
          inherit
            (pkgs)
            meson
            ninja
            pkg-config
            wrapGAppsHook4
            vala
            gobject-introspection
            blueprint-compiler
            dart-sass
            gawk
            ;
        };

        buildInputs = attrValues {
          inherit
            (astal.packages.${pkgs.stdenv.hostPlatform.system})
            io
            astal4
            apps
            battery
            bluetooth
            cava
            mpris
            network
            notifd
            river
            tray
            wireplumber
            ;

          inherit
            (pkgs)
            libadwaita
            libportal
            gtk4
            libnma-gtk4
            ;
        };
      };

      docs = let
        pname = "libkompass-docs";
        libkompass = self.packages.${pkgs.stdenv.hostPlatform.system}.libkompass;
        version = libkompass.version;
        girFile = "${libkompass}/share/gir-1.0/${libkompass.passthru.girName}.gir";
        data = (pkgs.formats.toml {}).generate "libkompass" {
          library = {
            description = "A collection of widgets useful for creating status bars using astal.";
            authors = "kotontrion";
            version = libkompass.version;
            license = "MIT";
            browse_url = "https://github.com/kotontrion/kompass/tree/main/libkompass";
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
        pkgs.stdenv.mkDerivation {
          inherit pname version;
          src = self;
          sourceRoot = "source/libkompass";
          nativeBuildInputs = attrValues {
            # Build Dependencies as declared in src/meson.build
            inherit
              (pkgs)
              libadwaita # libadwaita-1
              gobject-introspection
              gi-docgen
              ;

            inherit
              (astal.packages.${pkgs.stdenv.hostPlatform.system})
              apps # astal-apps-0.1
              bluetooth # astal-bluetooth-0.1
              io # astal-io-0.1
              cava # astal-cava-0.1
              mpris # astal-mpris-0.1
              network # astal-network-0.1
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
            license = pkgs.lib.licenses.lgpl3Only;
          };
        };

      default = self.packages.${pkgs.stdenv.hostPlatform.system}.kompass;
    });

    devShells = perSystem (pkgs: {
      default = pkgs.mkShell {
        nativeBuildInputs = with self.packages.${pkgs.stdenv.hostPlatform.system}; (kompass.nativeBuildInputs ++ libkompass.nativeBuildInputs);
        buildInputs = with self.packages.${pkgs.stdenv.hostPlatform.system}; (kompass.buildInputs ++ libkompass.buildInputs);

        inputsFrom = attrValues {
          inherit
            (self.packages.${pkgs.stdenv.hostPlatform.system})
            libkompass
            kompass
            ;
        };
      };
    });

    formatter = perSystem (pkgs: pkgs.alejandra);
  };
}
