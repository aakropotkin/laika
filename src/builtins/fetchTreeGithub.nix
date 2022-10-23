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

  fetchTreeGitW = {

    __functionMeta = {
      name      = "fetchTreeGithubW";
      from      = "builtins";
      innerName = "fetchTree";

      signature = let
        arg1_fields = {
          type = yt.enum ["github"];
          url  = yt.Uri.Strings.uri_ref;
          inherit (yt.Git) owner repo rev ref;
          narHash = option yt.Hash.sha256_sri;
        };
        # FIXME: I think `rev' might be parsed from `url' by `fetchTree'?
        # You need to test this.
        # REGARDLESS you need to toggle `optional' for each combo in `eitherN`.
        arg1_url = struct {
          inherit (arg1_fields) type url narHash;
          # FIXME: test
          rev   = yt.option yt.Git.rev;
          ref   = yt.option yt.Git.ref;
          owner = yt.option yt.Git.owner;
          repo  = yt.option yt.Git.repo;
        };
        arg1_attrs = struct {
          inherit (arg1_fields) type owner repo narHash;
          rev = if pure then yt.Git.rev else option yt.Git.rev;
          ref = yt.option yt.Git.ref;
          url = yt.option arg1_fields.url;
        };
        arg1 = yt.either arg1_url arg1_attrs;
      in [arg1 yt.SourceInfo.github];

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
      url        = true;
      owner      = true;
      repo       = true;
      ref        = true;    # Defaults to "refs/heads/HEAD"
      # FIXME: One of these is required in pure mode, but URL might cover?
      narHash    = true;
      rev        = true;    # Defaults to tip of `ref'
    };

    __innerFunction = builtins.fetchTree;

    # Stashed "auto-args" that can be set by users.
    # `ref' is intentionally omitted despite having a default.
    __thunk = {};

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

in fetchTreeGithubW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
