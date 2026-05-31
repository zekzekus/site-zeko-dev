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
          ];
          shellHook = ''
            echo "zeko.dev dev shell — $(zola --version)"
            echo "  zola serve   # live preview on http://127.0.0.1:1111"
            echo "  zola build   # produce ./public"
            echo "  zola check   # validate links and content"
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
