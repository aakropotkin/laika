# ============================================================================ #
#
# Nixpkgs libs extended with `liblaika' and other routines exposed
# by `./overlay.lib.nix'.
#
# ---------------------------------------------------------------------------- #

{ lib ? ( import ../inputs ).nixpkgs.flake.lib }:
   lib.extend ( import ./overlay.lib.nix )


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #