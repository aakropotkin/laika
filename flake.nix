{
  inputs.ak-nix.url = "github:aakropotkin/ak-nix";
  outputs = { ak-nix, ... }: let

    overlays.laika   = import ./overlay.nix;
    overlays.default = final: prev:
      ak-nix.lib.composeExtensions ak-nix.overlays.default overlays.laika;

    ytOverlays.laika   = import ./types/ytOverlay;
    ytOverlays.default = ytOverlays.laika;

    libOverlays.laika = final: prev: {
      lib = prev.lib.extend ( _: prevLib: {
        ytypes = prevLib.ytypes.extend ytOverlays.laika;
      } );
    };
    libOverlays.default = final: prev:
      ak-nix.lib.composeExtensions ak-nix.libOverlays.default libOverlays.laika;

  in {
    inherit overlays libOverlays ytOverlays;
  };
}
