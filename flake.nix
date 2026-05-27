{
  description = "iOpenPod — open-source iPod sync tool (Nix packaging)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem
      [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          python = pkgs.python312;

          wasmtime-py = python.pkgs.callPackage ./wasmtime-py.nix { };

          iopenpod = python.pkgs.callPackage ./package.nix {
            wasmtime = wasmtime-py;
            wrapQtAppsHook = pkgs.qt6Packages.wrapQtAppsHook;
          };
        in
        {
          packages = {
            inherit wasmtime-py iopenpod;
            default = iopenpod;
          };

          apps.default = flake-utils.lib.mkApp {
            drv = iopenpod;
            name = "iopenpod";
          };
        }
      )

    //

    {
      # Overlay for consuming this flake from another config (e.g. nix-config).
      # Usage in flake.nix:
      #   inputs.iopenpod-flake.url = "github:TristonYoder/iopenpod-flake";
      # Then in nixpkgs overlays:
      #   inputs.iopenpod-flake.overlays.default
      overlays.default = final: prev:
        let
          wasmtime-py = prev.python312Packages.callPackage ./wasmtime-py.nix { };
        in
        {
          iopenpod = prev.python312Packages.callPackage ./package.nix {
            wasmtime = wasmtime-py;
            wrapQtAppsHook = prev.qt6Packages.wrapQtAppsHook;
          };
        };
    };
}
