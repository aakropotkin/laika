{

  inputs.rime.url        = "github:aakropotkin/rime";
  inputs.nixpkgs.follows = "/rime/nixpkgs";

# ---------------------------------------------------------------------------- #

  outputs = { nixpkgs, rime, ... }: let

# ---------------------------------------------------------------------------- #

    ytOverlays.deps    = rime.ytOverlays.default;
    ytOverlays.laika   = import ./types/overlay.yt.nix;
    ytOverlays.default = nixpkgs.lib.composeExtensions ytOverlays.deps
                                                       ytOverlays.laika;


# ---------------------------------------------------------------------------- #

    libOverlays.deps  = rime.libOverlays.default;

    libOverlays.ytypes = final: prev: {
      ytypes = prev.ytypes.extend ytOverlays.laika;
    };

    libOverlays.libfetch = import ./src/overlay.lib.nix;

    libOverlays.laika = nixpkgs.lib.composeExtensions libOverlays.ytypes
                                                      libOverlays.libfetch;

    libOverlays.default = nixpkgs.lib.composeExtensions libOverlays.deps
                                                        libOverlays.laika;

    libOverlays.typecheck = nixpkgs.lib.composeExtensions ( final: prev: {
      laikaConfig = ( prev.laikaConfig or {} ) // { typecheck = true; };
    } ) libOverlays.default;

    libOverlays.pure = nixpkgs.lib.composeExtensions ( final: prev: {
      laikaConfig = ( prev.laikaConfig or {} ) // { pure = true; };
    } ) libOverlays.default;

    libOverlays.strict = nixpkgs.lib.composeExtensions ( final: prev: {
      laikaConfig = ( prev.laikaConfig or {} ) // {
        typecheck = true;
        pure      = true;
      };
    } ) libOverlays.default;


# ---------------------------------------------------------------------------- #

    overlays.deps    = rime.overlays.default;
    overlays.laika   = import ./overlay.nix;
    overlays.default = nixpkgs.lib.composeExtensions overlays.deps
                                                     overlays.laika;

    overlays.typecheck = nixpkgs.lib.composeExtensions ( _: prev: {
      lib = prev.lib.extend ( _: prevLib: {
        laikaConfig = ( prevLib.laikaConfig or {} ) // {
          typecheck = true;
        };
      } );
    } ) overlays.default;

    overlays.pure = nixpkgs.lib.composeExtensions ( _: prev: {
      lib = prev.lib.extend ( _: prevLib: {
        laikaConfig = ( prevLib.laikaConfig or {} ) // {
          pure = true;
        };
      } );
    } ) overlays.default;

    overlays.strict = nixpkgs.lib.composeExtensions ( _: prev: {
      lib = prev.lib.extend ( _: prevLib: {
        laikaConfig = ( prevLib.laikaConfig or {} ) // {
          typecheck = true;
          pure      = true;
        };
      } );
    } ) overlays.default;


# ---------------------------------------------------------------------------- #

    # Installable Packages for Flake CLI.
    packages = rime.lib.eachDefaultSystemMap ( system: let
      pkgsFor  = nixpkgs.legacyPackages.${system}.extend overlays.default;
      pkgsForT = nixpkgs.legacyPackages.${system}.extend overlays.typecheck;
    in {
      tests =
        ( pkgsFor.callPackages ./tests { nameExtra = "untyped"; } ).checkDrv;
      testsT =
        ( pkgsForT.callPackages ./tests { nameExtra = "typed"; } ).checkDrv;
    } );

# ---------------------------------------------------------------------------- #

  in {

# ---------------------------------------------------------------------------- #

    inherit overlays packages libOverlays ytOverlays;
    lib = nixpkgs.lib.extend libOverlays.default;

# ---------------------------------------------------------------------------- #

    checks = rime.lib.eachDefaultSystemMap ( system: {
      inherit (packages.${system}) tests testsT;
    } );


# ---------------------------------------------------------------------------- #

  };  # End Outputs
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
