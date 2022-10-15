{
  inputs.ak-nix.url = "github:aakropotkin/ak-nix";
  outputs = { self, ak-nix }: {
    overlays.ytypes  = import ./types/overlay.nix;
    overlays.default = self.overlays.ytypes;
  };
}
