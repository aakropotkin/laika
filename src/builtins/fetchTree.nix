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

    __processArgs = self: x: self.__thunk // x;

    # TODO: mercurial, sourcehut
    __functor = self: { type, ... } @ args: let
      fetchInfo  = self.__processArgs self args;
      sourceInfo = self.__innerFunction fetchInfo;
    in if type == "path"    then lib.libfetch.fetchTreePathW    args      else
       if type == "github"  then lib.libfetch.fetchTreeGithubW  args      else
       if type == "git"     then lib.libfetch.fetchTreeGitW     fetchInfo else
       if type == "tarball" then lib.libfetch.fetchTreeTarballW args      else
       if type == "file"    then lib.libfetch.fetchTreeFileW    args      else
       sourceInfo;
  };


# ---------------------------------------------------------------------------- #

in fetchTreeW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
