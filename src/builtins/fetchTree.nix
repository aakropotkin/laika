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

  # FIXME: ensure we align on `pure'.
  inners = [
    lib.libfetch.fetchTreePathW
    lib.libfetch.fetchTreeGithubW
    lib.libfetch.fetchTreeGitW
    lib.libfetch.fetchTreeTarballW
    lib.libfetch.fetchTreeFileW
  ];

  # Below we declare the list of `__functionArgs' explicitly, but this audits.
  allFunctionArgs = let
    len  = builtins.length inners;
    proc = _: vals:
      builtins.foldl' ( a: b: a || b ) ( ( builtins.length vals ) < len ) vals;
  in builtins.zipAttrsWith proc ( map ( x: x.__functionArgs ) inners );

  checkFunctionArgs = x: let
    loc = fetchTreeW.__functionMeta.from + "." + fetchTreeW.__functionMeta.name;
  in if allFunctionArgs == fetchTreeW.__functionArgs then x else
     throw "(${loc}): Mismatch in real and declared __functionArgs";


# ---------------------------------------------------------------------------- #

  fetchTreeW = {
    __functionMeta = {
      name      = "fetchTreeW";
      from      = "laika#lib.libfetch";
      innerName = "builtins.fetchTree";
      signature = let
        getArg1 = x: builtins.head x.__functionMeta.signature;
        arg1    = yt.eitherN ( map getArg1 inners );
      in [arg1 yt.SourceInfo.sourceInfo];

      properties = {
        inherit pure typecheck;
        builtin = true;
        family  = "fetchTree";  # kind of bogus
      };
    };

    __functionArgs = {
      # Common
      type    = false;  # The only mandatory arg in common.
      narHash = true;
      # `file'/`tarball'/`git' mode
      url = true;
      # `git'/`github' mode
      rev = true;
      ref = true;
      # `git' mode
      allRefs    = true;
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

    # Filter `__thunk' using the `__functionArgs' for the appropriate type.
    # I'm not in love with having this here at all, but I already wrote
    # everything else to accept `__thunk' and I'm not turning back now.
    #
    # TODO: mercurial, sourcehut, indirect
    __processArgs = self: { type, ... } @ x: let
      ti =
        if type == "path"    then lib.libfetch.fetchTreePathW    else
        if type == "github"  then lib.libfetch.fetchTreeGithubW  else
        if type == "git"     then lib.libfetch.fetchTreeGitW     else
        if type == "tarball" then lib.libfetch.fetchTreeTarballW else
        if type == "file"    then lib.libfetch.fetchTreeFileW    else
        throw "TODO: implement remaining wrappers";
      tm = builtins.intersectAttrs ti.__functionArgs self.__thunk;
    in tm // x;

    __functor = self: x: let
      checked = yt.defun self.__functionMeta.signature self.__innerFunction;
      fn      = if typecheck then checked else self.__innerFunction;
    in fn ( self.__processArgs self x );
  };


# ---------------------------------------------------------------------------- #

in checkFunctionArgs fetchTreeW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
