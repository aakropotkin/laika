# ============================================================================ #
#
# FIXME: this was migrated directly from `at-node-nix' but hasn't been rewritten
#
# fetchTree
#
# ---------------------------------------------------------------------------- #

{ lib
, pure      ? lib.inPureEvalMode
, typecheck ? false
}: let

  yt = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  inherit (yt) option struct bool;

# ---------------------------------------------------------------------------- #

  # FIXME: don't wrap output here
  fetchTreeW = {
    __functionArgs = {
      # Common
      type    = false;
      narHash = true;
      # `file'/`tarball'/`git' mode
      url = true;
      # `git'/`github' mode
      rev = true;
      ref = true;
      # `git' mode
      allRefs    = true;
      shortRev   = true;
      shallow    = true;
      submodules = true;
      # `github' mode
      owner = true;
      repo  = true;
      # `path' mode
      path = true;
    };

    # Copy the thunk from other fetchers.
    inherit (lib.libfetch.fetchTreeGitW) __thunk;

    __innerFunction = builtins.fetchTree;

    __processArgs = self: { type, ... } @ args: let
      # Reform `__functionArgs' to reflect given type.
      fa = if builtins.elem type ["tarball" "file"] then {
        url = false;
        # FIXME: only network URLs need `narHash'.
        narHash = ! pure;
      } else throw "Unrecognized `fetchTree' type: ${type}";
      fc = { type = false; narHash = true; };
      # Force `type' to appear, and inject the thunk from ``
      args' = args // { inherit type; };
    in builtins.intersectAttrs ( fa // fc ) args';

    __functor = self: { type, ... } @ args: let
      fetchInfo  = self.__processArgs self args;
      sourceInfo = self.__innerFunction fetchInfo;
    in if type == "path"    then lib.libfetch.fetchTreePathW args else
       if type == "github"  then lib.libfetch.fetchTreeGithubW args else
       if type == "git"     then lib.libfetch.fetchTreeGitW args else
       if type == "tarball" then lib.libfetch.fetchTreeTarballW args else
       if type == "file"    then lib.libfetch.fetchTreeFileW args else
       sourceInfo;
  };


# ---------------------------------------------------------------------------- #

in fetchTreeW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
