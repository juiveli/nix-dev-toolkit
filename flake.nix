# flake.nix
{
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  inputs.systems.url = "github:nix-systems/default";

  outputs =
    {
      self,
      nixpkgs,
      systems,
      treefmt-nix,
    }:
    let

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Small tool to iterate over each systems
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      treefmtModule = {
        programs.nixfmt.enable = true;
        programs.mdformat.enable = true;
      };

      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs treefmtModule);

    in
    {
      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
    };
}
