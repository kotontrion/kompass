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
  in {
    packages = perSystem (pkgs: {
      libkompass = pkgs.callPackage (
        {
          stdenv,
          lib,
          ...
        }: let
          inherit (lib) attrValues elemAt head match readFile splitString;
          getMesonValue = val: file:
            head (match "^([^']*).*" (elemAt (splitString val (readFile file)) 1));

          pname = "libkompass";
          version = getMesonValue "version: '" "${self}/subprojects/libkompass/meson.build";

          apiVersion = getMesonValue "api_version = '" "${self}/subprojects/libkompass/src/meson.build";
        in
          stdenv.mkDerivation {
            inherit pname version;

            src = self;
            sourceRoot = "source/subprojects/libkompass";

            nativeBuildInputs = attrValues {
              inherit
                (pkgs)
                blueprint-compiler
                dart-sass
                pkg-config
                libadwaita
                libportal
                gobject-introspection
                meson
                ninja
                vala
                wrapGAppsHook
                ;
              inherit
                (pkgs.gst_all_1)
                gstreamer
                gst-plugins-base
                ;
              inherit
                (astal.packages.${pkgs.system})
                io
                cava
                tray
                river
                ;
            };

            passthru.girName = "Kompass-${apiVersion}";

            meta = {
              license = lib.licenses.lgpl3Only;
            };
          }
      ) {};

      default = self.packages.${pkgs.system}.libkompass;
    });

    formatter = perSystem (pkgs: pkgs.alejandra);
  };
}
