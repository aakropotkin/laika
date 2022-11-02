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
    fetchTreeGitW    = callBuiltin ./builtins/fetchTreeGit.nix {};
    fetchTreeGithubW = callBuiltin ./builtins/fetchTreeGithub.nix {};
    fetchTreePathW   = callBuiltin ./builtins/fetchTreePath.nix {};
    fetchGitW        = callBuiltin ./builtins/fetchGit.nix {};
    pathW            = callBuiltin ./builtins/path.nix {};
    fetchurlDrv      = import ./fetchurlDrv/fetchurlDrvUnwrapped.nix;
    fetchurlDrvW = callBuiltin ./fetchurlDrv/fetchurlDrv.nix {
      inherit (final.libfetch) fetchurlDrv;
    };
  };
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
