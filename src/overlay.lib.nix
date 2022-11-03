# ============================================================================ #
#
# Lib overlay.
#
# ---------------------------------------------------------------------------- #

final: prev: let
  callBuiltin = x: let
    auto = { lib = final; } // ( final.laikaConfig or {} );  # pure/typecheck
    f    = import x;
    fa   = builtins.functionArgs f;
  in args: f ( builtins.intersectAttrs fa ( auto // args ) );
in {
  libfetch = ( prev.libfetch or {} ) // {
    fetchTreeW        = callBuiltin ./builtins/fetchTree.nix {};
    fetchTreeGitW     = callBuiltin ./builtins/fetchTreeGit.nix {};
    fetchTreeGithubW  = callBuiltin ./builtins/fetchTreeGithub.nix {};
    fetchTreePathW    = callBuiltin ./builtins/fetchTreePath.nix {};
    fetchTreeTarballW = callBuiltin ./builtins/fetchTreeTarball.nix {};
    fetchTreeFileW    = callBuiltin ./builtins/fetchTreeFile.nix {};
    fetchGitW         = callBuiltin ./builtins/fetchGit.nix {};
    pathW             = callBuiltin ./builtins/path.nix {};
    fetchurlDrv       = import ./fetchurlDrv/fetchurlDrvUnwrapped.nix;
    fetchurlDrvW      = callBuiltin ./fetchurlDrv/fetchurlDrv.nix {
      inherit (final.libfetch) fetchurlDrv;
    };

    # FIXME: move these to a subattr or `rime'.
    inherit (callBuiltin ./generic/git/parseGitUrlToArgs.nix {})
      isGithubUrl
      parseGitUrl
    ;
    inherit (callBuiltin ./generic/git/args.nix {})
      genericGitArgFields
      genericGitArgsPure
      genericGitArgsImpure
    ;
  };
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
