{
  description = "zeko.dev — personal site built with Zola";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          name = "site-zeko-dev";
          packages = [
            pkgs.zola
            pkgs.babashka
          ];
          shellHook = ''
            echo "zeko.dev dev shell — $(zola --version), $(bb --version)"
            echo ""
            echo "Tasks (run with 'bb <task>'):"
            bb tasks 2>/dev/null || true
          '';
        };

        # `nix build` produces the static site in ./result
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          pname = "site-zeko-dev";
          version = "0";
          src = ./.;
          nativeBuildInputs = [ pkgs.zola ];
          buildPhase = "zola build --output-dir $out";
          installPhase = "true"; # build already wrote to $out
        };
      });
}
