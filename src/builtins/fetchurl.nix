# ============================================================================ #
#
# fetchurlW
#
# ---------------------------------------------------------------------------- #

{ lib
, pure      ? lib.inPureEvalMode
, typecheck ? false
}: let

  yt = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  inherit (yt) option struct bool;

# ---------------------------------------------------------------------------- #

  fetchurlW = {

    __functionMeta = {
      name      = "fetchurlW";
      from      = "laika#lib.libfetch";
      innerName = "builtins.fetchurl";

      signature = let
        arg1_str   = yt.Uri.Strings.uri_ref;
        arg1_attrs = struct {
          name   = option yt.FS.Strings.filename;  # FIXME: store-path filename
          url    = yt.Uri.Strings.uri_ref;
          # CA hash
          sha256 = if pure then yt.Hash.sha256_sri else
                   option yt.Hash.sha256_sri;
        };
        arg1 = if pure then arg1_attrs else
               yt.either arg1_attrs arg1_str;
      in [arg1 yt.SourceInfo.tarball];

      properties = {
        inherit pure typecheck;
        builtin          = true;
        family           = "tarball";
        contentAddressed = true;
      };
    };

    # Basically the same as `builtins.path' but you can't pass `name', and must
    # pass `type = "path"'.
    __functionArgs = {
      url    = false;
      name   = true;
      sha256 = ! pure;
    };

    __innerFunction = builtins.fetchurl;

    # Stashed "auto-args" that can be set by users.
    __thunk = {};

    __processArgs = self: x: let
      asAttrs = if builtins.isAttrs x then x else { url = x; };
    in self.__thunk // asAttrs;

    # Typechecking is performed after `__processArgs'.
    # This allows us to add `type = "path"' as a `__thunk' in a less strict
    # form of this routine.
    __functor = self: x: let
      checked = yt.defun self.__functionMeta.signature self.__innerFunction;
      fn      = if typecheck then checked else self.__innerFunction;
    in fn ( self.__processArgs self x );
  };


# ---------------------------------------------------------------------------- #

in fetchurlW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
