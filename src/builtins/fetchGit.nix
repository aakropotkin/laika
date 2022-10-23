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
      innerName = "fetchGit";
      from      = "builtins";

      signature = let
        # FIXME: Handle pure
        arg1_attrs_impure = struct {
          url = yt.Uri.Strings.uri_ref;
          # FIXME: store path name restrictions
          name       = option yt.FS.Strings.filename;
          rev        = option yt.Git.rev;
          ref        = option yt.Git.ref;
          allRefs    = option bool;  # nixpkgs: sparseCheckout
          submodules = option bool;  # nixpkgs: fetchSubmodules
          shallow    = option bool;  # nixpkgs: deepClone?
        };
        arg1_string_impure = yt.Uri.Strings.uri_ref;
        arg1_impure = yt.either arg1_attrs arg1_string;
        arg1 = arg1_impure;
        #rsl = yt.SourceInfo.git;  # FIXME
        rsl = yt.any;
      in [arg1 rsl];

      properties = {
        inherit pure typecheck;
        builtin = true;
        family  = "git";
      };
    };

    __functionArgs = {
      url        = false;
      name       = true;   # Defaults to "source" XXX: docs are wrong.
      allRefs    = true;   # Defaults to false
      shallow    = true;   # Defaults to false
      submodules = true;   # Defaults to false
      # FIXME: Depends on pure mode
      ref = true;  # Defaults to `refs/heads/HEAD'
      rev = true;  # Defaults to tip of `ref'
    };

    __innerFunction = builtins.fetchGit;

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
      inner = {
        url
      , name       ? "source"
      , submodules ? self.__thunk.submodules
      , allRefs    ? self.__thunk.allRefs
      , shallow    ? self.__thunk.shallow
      , ref        ? if ( args ? rev ) && allRefs then null
                                                  else "refs/heads/HEAD"
      , rev        ? null
      , ...
      } @ args:
      builtins.intersectAttrs ( self.__thunk // args ) self.__functionArgs;
    in if builtins.isString x then inner { url = x; } else inner x;

    __functor = self: args: let
      unchecked = self.__innerFunction ( self.__processArgs args );
      checked   = yt.defun fetchGitW.__functionMeta.signature unchecked;
    in if typecheck then checked else unchecked;
  };


# ---------------------------------------------------------------------------- #

in fetchGitW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
