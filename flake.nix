{
  inputs.ak-nix.url = "github:aakropotkin/ak-nix";
  outputs = { ak-nix, ... }: let

    ytOverlays.laika   = import ./types/overlay.yt.nix;
    ytOverlays.default = ytOverlays.laika;

    libOverlays.deps  = ak-nix.libOverlays.default;
    libOverlays.laika = final: prev: {
      ytypes = prev.ytypes.extend ytOverlays.laika;
    };
    libOverlays.default = final: prev:
      ak-nix.lib.composeExtensions libOverlays.deps libOverlays.laika;

    overlays.laika   = import ./overlay.nix;
    overlays.default = final: prev:
      ak-nix.lib.composeExtensions ak-nix.overlays.default overlays.laika;

  in {
    inherit overlays libOverlays ytOverlays;
  };
}
