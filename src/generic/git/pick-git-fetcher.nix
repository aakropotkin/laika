# ============================================================================ #
#
# FIXME: currently this returns either a function or a string which makes
# no sense.
#
# This was largely moved over for reference because the logic itself is useful.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  inherit (lib.libfetch) fetchTreeGitW fetchTreeGithubW fetchGitW;


# ---------------------------------------------------------------------------- #

  # Takes `genericGitArgFields' as its second argument.
  # In pure mode we really get choosy based on which type of `hash' or `rev'
  # was provided.
  # Returns a flake-ref URI for non-builtins.
  pickGitFetcherFromArgs' = pure: args: let
    hash = args.hash or ( lib.apply tagHash args );
    pMissingRev = pure && ( ! ( args ? rev ) );
    # In pure mode we can fetch without `rev' if `narHash' is given.
    pMissingNarHash = pure && ( ! ( hash ? narHash ) );
    isGithub        = ( args.type == "github" ) || ( isGithubUrl args.url );
    preferFTGithub  = ( args ? owner ) || ( args ? repo ) || isGithub;
    ftg = if preferFTGithub then fetchTreeGithubW else fetchTreeGitW;
  in if pMissingRev && pMissingNarHash then "nixpkgs#fetchgit" else
     if pMissingNarHash then ftg else
     # Regardless of purity, if a hash is given we'll assume the user meant for
     # us to take advantage of it using `nixpkgs#fetchgit'.
     if args ? hash then "nixpkgs#fetchgit" else
     # Try to use `fetchTree{ type = "github"; }' whenver possible.
     if preferFTGithub then fetchTreeGithubW else
     fetchGitW;

  pickGitFetcherFromArgsPure   = pickGitFetcherFromArgs' true;
  pickGitFetcherFromArgsImpure = pickGitFetcherFromArgs' false;


# ---------------------------------------------------------------------------- #

in {
  inherit
    pickGitFetcherFromArgs'
    pickGitFetcherFromArgsPure
    pickGitFetcherFromArgsImpure
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
