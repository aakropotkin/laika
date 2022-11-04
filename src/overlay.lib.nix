# ============================================================================ #
#
# Lib overlay.
#
# NOTE: I'm not nuts about the configured sub-attrs, but I'm also not crazy
# about making each fetcher carry more args or live inside of an
# `makeOverridable' style attrset.
#
# TODO: Isolate fetchers that are sensitive to purity/typecheck from other lib
# routines, particularly `./generic/' routines.
# Unfortunately some of those take top-level `pure' and `typecheck' args now.
#
# ---------------------------------------------------------------------------- #

final: prev: let

  callConfiguredWith = laikaConfig: x: let
    auto = { lib = final; } // laikaConfig;  # pure/typecheck
    f    = import x;
    fa   = builtins.functionArgs f;
  in args: f ( builtins.intersectAttrs fa ( auto // args ) );


# ---------------------------------------------------------------------------- #

  # This constructor configures all fetchers with the args:
  #   - pure
  #   - typecheck
  # XXX: This is not a long term solution to handling these configs.
  # See note above, there more likely needs to be 2-4 clones of each function
  # in a more organized set of sub-attrs to keep things sane.
  mkFetchers = laikaConfig: let
    callConfigured = callConfiguredWith ( laikaConfig // {
      lib = final // {
        libfetch = ( final.libfetch or {} ) // fetchers;
      };
    } );
    fetchers = {
      fetchTreeW        = callConfigured ./builtins/fetchTree.nix {};
      fetchTreeGitW     = callConfigured ./builtins/fetchTreeGit.nix {};
      fetchTreeGithubW  = callConfigured ./builtins/fetchTreeGithub.nix {};
      fetchTreePathW    = callConfigured ./builtins/fetchTreePath.nix {};
      fetchTreeTarballW = callConfigured ./builtins/fetchTreeTarball.nix {};
      fetchTreeFileW    = callConfigured ./builtins/fetchTreeFile.nix {};
      fetchGitW         = callConfigured ./builtins/fetchGit.nix {};
      pathW             = callConfigured ./builtins/path.nix {};
      fetchurlW         = callConfigured ./builtins/fetchurl.nix {};
      fetchurlDrvW      = callConfigured ./fetchurlDrv/fetchurlDrv.nix {
        inherit (final.libfetch) fetchurlDrv;
      };
    };
  in fetchers;  # End `mkFetchers'


# ---------------------------------------------------------------------------- #

in {

  # Default implementation using `final.laikaConfig' lives at top level.
  # Explicitly configured forms live in `[Pure|Impure](Typed|Untyped)' subattrs.
  libfetch = let
    existing = prev.libfetch or {};
    callLib  = f: args: import f ( { lib = final; } // args );
    default  = mkFetchers ( final.laikaConfig or {} );
  in existing // default // {

    # Common libs that aren't effected by configs.
    fetchurlDrv = import ./fetchurlDrv/fetchurlDrvUnwrapped.nix;

    # FIXME: move these to a subattr or `rime'.
    inherit (callLib ./generic/git/parseGitUrlToArgs.nix {})
      isGithubUrl
      parseGitUrl
    ;
    inherit (callLib ./generic/git/args.nix {})
      genericGitArgFields
      genericGitArgsPure
      genericGitArgsImpure
    ;

    inherit (callLib ./generic/url/args.nix {})
      genericUrlArgFields
      asGenericUrlArgsPure     asGenericUrlArgsImpure
      asGenericFileArgsPure    asGenericFileArgsImpure
      asGenericTarballArgsPure asGenericTarballArgsImpure
      # FIXME: you don't provide a minimum argset yet.
    ;


# ---------------------------------------------------------------------------- #

    # Configured Fetchers
    PureTyped     = mkFetchers { pure = true;  typecheck = true; };
    PureUntyped   = mkFetchers { pure = true;  typecheck = false; };
    ImpureTyped   = mkFetchers { pure = false; typecheck = true; };
    ImpureUntyped = mkFetchers { pure = false; typecheck = false; };
    Typed   = mkFetchers { pure = final.inPureEvalMode; typecheck = true; };
    Untyped = mkFetchers { pure = final.inPureEvalMode; typecheck = false; };


# ---------------------------------------------------------------------------- #

  };  # End `libfetch'

}  # End `lib'


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
