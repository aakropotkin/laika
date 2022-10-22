{
  inputs.ak-nix.url      = "github:aakropotkin/ak-nix";
  inputs.nixpkgs.follows = "/ak-nix/nixpkgs";

  outputs = { nixpkgs, ak-nix, ... }: let

    ytOverlays.laika   = import ./types/overlay.yt.nix;
    ytOverlays.default = ytOverlays.laika;

    libOverlays.deps  = ak-nix.libOverlays.default;
    libOverlays.laika = final: prev: {
      ytypes = prev.ytypes.extend ytOverlays.laika;
    };
    libOverlays.default = ak-nix.lib.composeExtensions libOverlays.deps
                                                       libOverlays.laika;

    overlays.laika   = import ./overlay.nix;
    overlays.default = ak-nix.lib.composeExtensions ak-nix.overlays.default
                                                    overlays.laika;

  in {
    lib = nixpkgs.lib.extend libOverlays.default;
    inherit overlays libOverlays ytOverlays;
  };
}
