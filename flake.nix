{
  inputs.rime.url        = "github:aakropotkin/rime";
  inputs.nixpkgs.follows = "/rime/nixpkgs";

  outputs = { nixpkgs, rime, ... }: let

    ytOverlays.deps    = rime.ytOverlays.default;
    ytOverlays.laika   = import ./types/overlay.yt.nix;
    ytOverlays.default = nixpkgs.lib.composeExtensions ytOverlays.deps
                                                       ytOverlays.laika;

    libOverlays.deps  = rime.libOverlays.default;
    libOverlays.laika = final: prev: {
      ytypes = prev.ytypes.extend ytOverlays.laika;
    };
    libOverlays.default = nixpkgs.lib.composeExtensions libOverlays.deps
                                                        libOverlays.laika;

    overlays.deps    = rime.overlays.default;
    overlays.laika   = import ./overlay.nix;
    overlays.default = nixpkgs.lib.composeExtensions overlays.deps
                                                     overlays.laika;

  in {
    lib = nixpkgs.lib.extend libOverlays.default;
    inherit overlays libOverlays ytOverlays;

# ---------------------------------------------------------------------------- #

    # Installable Packages for Flake CLI.
    packages = rime.lib.eachDefaultSystemMap ( system: let
      pkgsFor   = nixpkgs.legacyPackages.${system}.extend overlays.default;
      testSuite = pkgsFor.callPackages ./tests {};
    in {
      tests = testSuite.checkDrv;
    } );


# ---------------------------------------------------------------------------- #

  };  # End Outputs
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
