# ============================================================================ #
#
# fetchTreeGithubW
#
# ---------------------------------------------------------------------------- #

{ lib
, pure      ? lib.inPureEvalMode
, typecheck ? false
}: let

  yt = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  inherit (yt) option struct bool;

# ---------------------------------------------------------------------------- #

  fetchTreeGithubW = {

    __functionMeta = {
      name      = "fetchTreeGithubW";
      from      = "laika#lib.libfetch";
      innerName = "builtins.fetchTree";

      signature = let
        arg1_fields = {
          type = yt.enum ["github"];
          inherit (yt.Git) owner repo rev ref;
          narHash = option yt.Hash.nar_hash;
        };
        # In pure mode either `narHash' or `rev' must be specified.
        # In practice `narHash' is worthless because it'll be blown out as soon
        # as a new ref is pushed; but there's technically use cases.
        # FIXME: fix the restriction or use eithers.
        arg1 = struct {
          inherit (arg1_fields) type owner repo narHash;
          rev = if pure then yt.Git.rev else option yt.Git.rev;
          ref = yt.option yt.Git.ref;
        };
      in [arg1 yt.SourceInfo.github];

      properties = {
        inherit pure typecheck;
        builtin = true;
        family  = "git";
      };
    };

    __functionArgs = {
      type       = false;   # Must be "github"
      owner      = true;
      repo       = true;
      ref        = true;    # Defaults to "refs/heads/HEAD"
      # XXX: One of these is required in pure mode.
      narHash    = true;
      rev        = true;    # Defaults to tip of `ref'
    };

    __innerFunction = builtins.fetchTree;

    # Stashed "auto-args" that can be set by users.
    # `ref' is intentionally omitted despite having a default.
    __thunk = {};

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

in fetchTreeGithubW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
