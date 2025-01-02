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
                io # astal-io-0.1
                cava # astal-cava-0.1
                tray # astal-tray-0.1
                river # astal-river-0.1
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
                meson
                ninja
                pkg-config
                vala
                ;
            };

            passthru.girName = "Kompass-${apiVersion}";

            meta = {
              license = lib.licenses.lgpl3Only;
            };
          }
      ) {};
    });

    formatter = perSystem (pkgs: pkgs.alejandra);
  };
}
