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
        # FIXME: I think `rev' might be parsed from `url' by `fetchTree'?
        # You need to test this.
        # REGARDLESS you need to toggle `optional' for each combo in `eitherN`.
        arg1 = struct {
          type       = yt.enum ["git"];
          url        = yt.Uri.Strings.uri_ref;
          rev        = if pure then yt.Git.rev else option yt.Git.rev;
          ref        = option yt.Git.ref;
          allRefs    = option bool;  # nixpkgs: sparseCheckout
          submodules = option bool;  # nixpkgs: fetchSubmodules
          shallow    = option bool;  # nixpkgs: deepClone?
          narHash    = option yt.Hash.narHash;
        };
      in [arg1 yt.SourceInfo.git];

      properties = {
        inherit pure typecheck;
        builtin = true;
        family  = "git";
      };
    };

    # Basically the same as `fetchGit' but you can't pass `name', and must
    # pass `type = "git"'.
    __functionArgs = {
      type       = false;   # Must be "git"
      url        = false;
      allRefs    = true;    # Defaults to false
      shallow    = true;    # Defaults to false
      submodules = true;    # Defaults to false
      ref        = true;    # Defaults to "refs/heads/HEAD"
      # FIXME: One of these is required in pure mode, but URL might cover?
      narHash    = true;
      rev        = true;    # Defaults to tip of `ref'
    };

    __innerFunction = builtins.fetchTree;

    # Stashed "auto-args" that can be set by users.
    # These align with the defaults.
    # `ref' is intentionally omitted despite having a default.
    __thunk = {
      submodules = false;
      shallow    = false;
      allRefs    = false;
    };

    # NOTE: Don't try to parse `rev' here, do that elsewhere.
    # Keep this routine "strict" in alignment with Nix.
    __processArgs = self: x: self.__thunk // x;

    # Typechecking is performed after `__processArgs'.
    # This allows us to add `type = "git"' as a `__thunk' in a less strict
    # form of this routine.
    __functor = self: x: let
      checked = yt.defun self.__functionMeta.signature self.__innerFunction;
      fn      = if typecheck then checked else self.__innerFunction;
    in fn ( self.__processArgs self x );
  };


# ---------------------------------------------------------------------------- #

in fetchTreeGitW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
