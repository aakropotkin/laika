# ============================================================================ #
#
# fetchGitW
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  yt = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  inherit (yt) option struct bool;


# ---------------------------------------------------------------------------- #

in {

  __functionMeta = {
    name      = "fetchGitW";
    innerName = "fetchGit";
    from      = "builtins";
    signature = let
      # FIXME
      arg1 = struct {
        url = yt.Uri.Strings.uri_ref;
        # FIXME: store path name restrictions
        name       = option yt.FS.Strings.filename;
        rev        = option yt.Git.rev;
        ref        = option yt.Git.ref;
        allRefs    = option bool;  # nixpkgs: sparseCheckout
        submodules = option bool;  # nixpkgs: fetchSubmodules
        shallow    = option bool;  # nixpkgs: deepClone?
      };
      rsl = yt.FS.store_path;
    in [arg1 rsl];
  };

  __functionArgs = {
    url        = false;
    name       = true;   # Store path name to put outdir
    allRefs    = true;   # Defaults to false
    shallow    = true;   # Defaults to false
    submodules = true;   # Defaults to false
    # FIXME: Depends on pure mode
    ref = true;  # Defaults to `refs/heads/HEAD'
    rev = true;  # Defaults to tip of `ref'
  };

  __thunk   = {
    submodules = false;
    shallow    = false;
    allRefs    = false;
  };

  __innerFunction = builtins.fetchGit;

  __functor = self: args: lib.callWith self.__thunk self.__innerFunction;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
