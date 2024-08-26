{
  description = "base16x2";

  inputs = { 
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = inputs @ 
  { self
  , nixpkgs
  , systems
  , ... 
  }:
  let
    eachSystem = nixpkgs.lib.genAttrs (import systems);

    pkgsFor = (system: import nixpkgs {
      inherit system;
      overlays = [ ];
    });
  in 
  {
    nixosModules.default = import ./nix/module.nix self;

    homeManagerModules.default = self.nixosModule;
  };
}
