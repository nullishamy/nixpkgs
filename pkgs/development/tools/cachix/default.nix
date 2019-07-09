{ haskellPackages, haskell }:

(haskellPackages.override {
  overrides = self: super: {
    cachix = haskell.lib.enableSeparateBinOutput (haskell.lib.doDistribute (self.cachix_0_2_1 or self.cachix));
    cachix-api = self.cachix-api_0_2_1 or self.cachix-api;
  };
}).cachix.bin
