# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  # TODO

  nt = lib.types;
  lt = { inherit (lib.liblaika) inputScheme; };


# ---------------------------------------------------------------------------- #

in {

  _file = "<laika>/schemes/implementation.default.nix";

  config.schemes = {

    indirect  = [lt.inputScheme];
    tarball   = [lt.inputScheme];
    file      = [lt.inputScheme];
    path      = [lt.inputScheme];
    git       = [lt.inputScheme];
    mercurial = [lt.inputScheme];
    github    = [lt.inputScheme];
    gitlab    = [lt.inputScheme];
    sourcehut = [lt.inputScheme];

  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
