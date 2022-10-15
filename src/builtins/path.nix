# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let
  yt = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  inherit (yt) option struct either function bool string;
  inherit (yt.fs) filename;

# ---------------------------------------------------------------------------- #

  self = {
    from = "builtins";
    name = "path";

    inputs = let
      args = struct "${self.from}.${self.name}:args" {
        name      = option filename;
        path      = true;
        resolved  = true;
        filter    = true;
        recursive = true;
        sha256    = true;
        outPath   = true;
      };
    in [args];

    outputs = {
    };

    function = builtins.path;
  };


# ---------------------------------------------------------------------------- #

in self


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
