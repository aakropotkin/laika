# ============================================================================ #
#
# pathW
#
# FIXME: typecheck and "pure" mode.
#
# ---------------------------------------------------------------------------- #

{ lib
, pure     ? lib.inPureEvalMode
, typcheck ? false
}: let

  yt = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  inherit (yt) option struct either function bool string;

# ---------------------------------------------------------------------------- #

in {

  __functionMeta = {
    name      = "pathW";
    innerName = "path";
    from      = "builtins";
    # As a function signature
    signature = let
      arg1 = struct {
        # FIXME: nix store pathname restrictions
        name      = option yt.FS.Strings.filename;
        path      = yt.FS.abspath;
        filter    = option function;
        recursive = option bool;
        sha256    = option yt.Hash.sha256;
      };
    in [arg1 yt.FS.store_path];
  };

  __functionArgs = {
    name      = true;
    path      = false;
    filter    = true;
    recursive = true;
    #sha256    = ! pure;
    sha256    = true;  # FIXME: this seems to work if you're under a git tree.
  };

  __innerFunction = builtins.path;

  __functor = self: self.__innerFunction;

}


# ---------------------------------------------------------------------------- #



# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
