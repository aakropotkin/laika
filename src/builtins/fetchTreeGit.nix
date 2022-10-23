# ============================================================================ #
#
# fetchTreeGitW
#
# ---------------------------------------------------------------------------- #

{ lib
, pure      ? lib.inPureEvalMode
, typecheck ? false
}: let

  yt = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  inherit (yt) option struct bool;

# ---------------------------------------------------------------------------- #

  fetchTreeGitW = {

    __functionMeta = {
      name      = "fetchTreeGitW";
      from      = "builtins";
      innerName = "fetchTree";

      signature = let
        arg1 = struct {
          type       = yt.enum ["git"];
          url        = yt.Uri.Strings.uri_ref;
          rev        = if pure then yt.Git.rev else option yt.Git.rev;
          ref        = option yt.Git.ref;
          allRefs    = option bool;  # nixpkgs: sparseCheckout
          submodules = option bool;  # nixpkgs: fetchSubmodules
          shallow    = option bool;  # nixpkgs: deepClone?
        };
      in [arg1 yt.SourceInfo.git];

      properties = {
        inherit pure typecheck;
        builtin = true;
        family  = "git";
      };
    };

    # Basically the same as `fetchTree' but you can't pass `name', and must
    # pass `type = "git"'.
    __functionArgs = {
      type       = false;   # Must be "git"
      url        = false;
      allRefs    = true;    # Defaults to false
      shallow    = true;    # Defaults to false
      submodules = true;    # Defaults to false
      ref        = true;    # Defaults to "refs/heads/HEAD"
      rev        = ! pure;  # Defaults to tip of `ref'
    };

    __innerFunction = builtins.fetchTree;

    # Stashed "auto-args" that can be set by users.
    # These align with the defaults.
    # `ref' and `name' are intentionally omitted despite having defaults.
    __thunk = {
      submodules = false;
      shallow    = false;
      allRefs    = false;
    };

    # NOTE: Don't try to parse `rev' here, do that elsewhere.
    # Keep this routine "strict" in alignment with Nix.
    __processArgs = self: x: self.__thunk // args;

    # Typechecking is performed after `__processArgs'.
    # This allows us to add `type = "git"' as a `__thunk' in a less strict
    # form of this routine.
    __functor = self: x: let
      checked = yt.defun self.__functionMeta.signature self.__innerFunction;
      fn      = if typecheck then checked else self.__innerFunction;
    in fn ( self.__processArgs x );
  };


# ---------------------------------------------------------------------------- #

in fetchTreeGitW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
