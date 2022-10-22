# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let
  yt = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  inherit (yt) option struct either function bool string;
  inherit (yt.fs) filename abspath store_path;

# ---------------------------------------------------------------------------- #

  self = {
    from = "builtins";
    name = "path";

    # As a function signature
    inputs = let
      arg1 = struct "${self.from}.${self.name}:args" {
        name      = option filename;   # FIXME: nix store pathname restrictions
        path      = abspath;
        filter    = option function;
        recursive = option bool;
        sha256    = option yt.Hash.sha256;
      };
    in [arg1];

    outputs = yt.fs.store_path;

    function = builtins.path;
  };


# ---------------------------------------------------------------------------- #

in self


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
