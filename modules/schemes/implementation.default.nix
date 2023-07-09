# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  # TODO

  nt = lib.types;
  lt = { inherit (lib.liblaika) inputSchemeDeferred; };


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
    github    = [lt.inputSchemeDeferred ./github-like/implementation.nix];
    gitlab    = [
      lt.inputSchemeDeferred ./github-like/implementation.nix
      { config.name = "gitlab"; }
    ];
    sourcehut = [
      lt.inputSchemeDeferred ./github-like/implementation.nix
      { config.name = "sourcehut"; }
    ];

  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
