# ============================================================================ #
#
# fetchTreePathW
#
# ---------------------------------------------------------------------------- #

{ lib
, pure      ? lib.inPureEvalMode
, typecheck ? false
}: let

  yt = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  inherit (yt) option struct bool;

# ---------------------------------------------------------------------------- #

  fetchTreePathW = {

    __functionMeta = {
      name      = "fetchTreePathW";
      from      = "laika#lib.libfetch";
      innerName = "builtins.fetchTree";

      # NOTE: The actual `builtins.fetchTree' does NOT accept a `url', the
      # handler for that is specific to `flake:inputs' fixup, and we will don't
      # handle that here.
      # Remember: the point of these wrappers is to excplicitly align with the
      # builtins, so any quality of life fixup needs to happen in a wrapper.
      signature = let
        arg1 = struct {
          type    = yt.enum ["path"];
          path    = yt.FS.abspath;
          narHash = if pure then yt.Hash.narHash else option yt.Hash.narHash;
        };
      in [arg1 yt.SourceInfo.path];

      properties = {
        inherit pure typecheck;
        builtin = true;
        family  = "path";
      };
    };

    # Basically the same as `builtins.path' but you can't pass `name', and must
    # pass `type = "path"'.
    __functionArgs = {
      type    = false;  # Must be "path"
      path    = false;
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

in fetchTreePathW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
