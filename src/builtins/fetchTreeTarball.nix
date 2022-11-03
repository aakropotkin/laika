# ============================================================================ #
#
# fetchTreeTarballW
#
# ---------------------------------------------------------------------------- #

{ lib
, pure      ? lib.inPureEvalMode
, typecheck ? false
}: let

  yt = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  inherit (yt) option struct bool;

# ---------------------------------------------------------------------------- #

  fetchTreeTarballW = {

    __functionMeta = {
      name      = "fetchTreeTarballW";
      from      = "laika#lib.libfetch";
      innerName = "builtins.fetchTree";

      signature = let
        arg1 = struct {
          type    = yt.enum ["tarball"];
          url     = yt.Uri.Strings.uri_ref;
          narHash = if pure then yt.Hash.narHash else option yt.Hash.narHash;
        };
      in [arg1 yt.SourceInfo.tarball];

      properties = {
        inherit pure typecheck;
        builtin = true;
        family  = "tarball";
      };
    };

    # Basically the same as `builtins.path' but you can't pass `name', and must
    # pass `type = "path"'.
    __functionArgs = {
      type    = false;  # Must be "path"
      url     = false;
      narHash = ! pure;
    };

    __innerFunction = builtins.fetchTree;

    # Stashed "auto-args" that can be set by users.
    __thunk = {};

    __processArgs = self: x: self.__thunk // x;

    # Typechecking is performed after `__processArgs'.
    # This allows us to add `type = "path"' as a `__thunk' in a less strict
    # form of this routine.
    __functor = self: x: let
      checked = yt.defun self.__functionMeta.signature self.__innerFunction;
      fn      = if typecheck then checked else self.__innerFunction;
    in fn ( self.__processArgs self x );
  };


# ---------------------------------------------------------------------------- #

in fetchTreeTarballW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
