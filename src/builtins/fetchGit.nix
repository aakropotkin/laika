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
        arg1_impure = yt.either arg1_attrs arg1_string;
        arg1 = if pure then arg1_attrs else arg1_impure;
        rsl = yt.Fetch.sourceInfo_git;
      in [arg1 rsl];

      properties = {
        inherit pure typecheck;
        builtin = true;
        family  = "git";
      };
    };

    __functionArgs = {
      url        = false;
      name       = true;   # Defaults to "source". XXX: docs are wrong.
      allRefs    = true;   # Defaults to false
      shallow    = true;   # Defaults to false
      submodules = true;   # Defaults to false
      ref        = true;    # Defaults to `refs/heads/HEAD'
      rev        = ! pure;  # Defaults to tip of `ref'
    };

    __innerFunction = builtins.fetchGit;

    # Stashed "auto-args" that can be set by users.
    __thunk = {
      submodules = false;
      shallow    = false;
      allRefs    = false;
    };

    # NOTE: Don't try to parse `rev' here, do that elsewhere.
    # Keep this routine "strict" in alignment with Nix.
    __processArgs = self: x: let
      # NOTE: most of these defaults are written for reference, we only take
      # "thunked" fallbacks.
      # This is mostly because I'm not certain that specifying `ref` in
      # combination with `allRefs` and `rev` is "well defined".
      inner = {
        url
      , name       ? "source"  # XXX: Nix docs incorrectly say basename of url
      , submodules ? self.__thunk.submodules or null
      , allRefs    ? self.__thunk.allRefs    or null
      , shallow    ? self.__thunk.shallow    or null
      , ref        ? "refs/heads/HEAD"
      , rev        ? null
      } @ args: self.__thunk // args;
    in if builtins.isString x then inner { url = x; } else inner x;

    # FIXME: YANTS' `defun' sucks for this because it botches our fn names.
    # Run the typecheck manually.
    # Deferring until after receiving `args' helps.
    __functor = self: args: let
      unchecked = self.__innerFunction ( self.__processArgs args );
      checked   = yt.defun self.__functionMeta.signature unchecked;
    in if typecheck then checked else unchecked;
  };


# ---------------------------------------------------------------------------- #

in fetchGitW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
