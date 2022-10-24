# ============================================================================ #
#
# fetchGitW
#
# ---------------------------------------------------------------------------- #

{ lib
, pure      ? lib.inPureEvalMode
, typecheck ? false
}: let

  yt = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  inherit (yt) option struct bool;

# ---------------------------------------------------------------------------- #

  fetchGitW = {

    __functionMeta = {
      name      = "fetchGitW";
      from      = "builtins";
      innerName = "fetchGit";

      signature = let
        arg1_attrs = struct {
          url = yt.Uri.Strings.uri_ref;
          # FIXME: store path name restrictions
          name       = option yt.FS.Strings.filename;
          rev        = if pure then yt.Git.rev else option yt.Git.rev;
          ref        = option yt.Git.ref;
          allRefs    = option bool;  # nixpkgs: sparseCheckout
          submodules = option bool;  # nixpkgs: fetchSubmodules
          shallow    = option bool;  # nixpkgs: deepClone?
        };
        arg1_string_impure = yt.Uri.Strings.uri_ref;
        arg1_impure        = yt.either arg1_attrs arg1_string_impure;
        arg1               = if pure then arg1_attrs else arg1_impure;
      in [arg1 yt.SourceInfo.git];

      properties = {
        inherit pure typecheck;
        builtin = true;
        family  = "git";
      };
    };

    __functionArgs = {
      url        = false;
      name       = true;    # Defaults to "source". XXX: docs are wrong.
      allRefs    = true;    # Defaults to false
      shallow    = true;    # Defaults to false
      submodules = true;    # Defaults to false
      ref        = true;    # Defaults to "refs/heads/HEAD"
      rev        = ! pure;  # Defaults to tip of `ref'
    };

    __innerFunction = builtins.fetchGit;

    # Stashed "auto-args" that can be set by users.
    # These align with the defaults.
    # `ref' and `name' are intentionally omitted despite having defaults.
    __thunk = {
      submodules = false;
      #shallow    = false;
      #allRefs    = false;
    };

    # NOTE: Don't try to parse `rev' here, do that elsewhere.
    # Keep this routine "strict" in alignment with Nix.
    __processArgs = self: x: let
      args = if builtins.isString x then { url = x; } else x;
    in self.__thunk // args;

    # Typechecking is performed after `__processArgs'.
    # This allows users to extend `__processArgs' with shims more easily.
    __functor = self: x: let
      checked = yt.defun self.__functionMeta.signature self.__innerFunction;
      fn      = if typecheck then checked else self.__innerFunction;
    in fn ( self.__processArgs self x );
  };


# ---------------------------------------------------------------------------- #

in fetchGitW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
