# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  yt  = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;

# ---------------------------------------------------------------------------- #

  nixpkgsFetchgitArgs = {
    name = true;
    url  = false;
    # Options
    branchName = true;
    deepClone  = true;
    fetchLFS   = true;
    fetchSubmodules = true;
    leaveDotGit     = true;
    sparseCheckout  = true;
    # One of
    hash   = true;
    sha256 = true;
    md5    = true;
    rev    = true;
    # ...
  };


  # NOTE: If a hostname has a `git@' ( ssh ) prefix, it MUST use a ":", not
  #       "/" to separate the hostname and path.
  #       Nix's `fetchGit' and `fetchTree' do not use a ":" here, so replace
  #       it with "/" - if you don't, you'll get an error:
  #       "make sure you have access rights".
  # builtins.fetchGit { url = "git+ssh://git@github.com/lodash/lodash.git#2da024c3b4f9947a48517639de7560457cd4ec6c"; }
  # builtins.fetchTree { type = "git"; url = "git+ssh://git@github.com/lodash/lodash.git#2da024c3b4f9947a48517639de7560457cd4ec6c"; }
  # NOTE: You must provide `type = "git";' for `fetchTree' it doesn't parse
  #       the URI to try and guess ( flake refs will ).
  # NOTE: You must leave the "<path>#<rev>" as is for the builtin fetchers -
  #       a "<path>/<rev>" will not work; but I think flake inputs DO want it
  #       replaced with a "/".
  genericGitArgFields = {
    name  = yt.FS.Strings.filename;  # for `nixpkgs.fetchgit' this is the outdir
    type  = yt.enum ["git" "github" "sourcehut"];
    #url   = yt.FlakeRef.Strings.git_ref;
    url   = yt.Uri.Strings.uri_ref;
    flake = yt.bool;
    inherit (yt.Git) rev ref;     # `branchName' is alias of `ref' for `nixpkgs'
    inherit (yt.Hash.Sums) hash;  # nixpkgs accepts a slew of options.
    allRefs    = yt.bool;  # nixpkgs: sparseCheckout
    submodules = yt.bool;  # nixpkgs: fetchSubmodules
    shallow    = yt.bool;  # nixpkgs: deepClone?
    repo       = yt.Git.Strings.ref_component;
    owner      = yt.Git.Strings.owner;
  };

  genericGitArgs' = pure: let
    checkPresent = x: let
      comm = builtins.intersectAttrs x genericGitArgFields;
    in builtins.all ( k: comm.${k}.check x.${k} ) ( builtins.attrNames comm );
    minimal = x: builtins.all ( p: p ) [
      # `builtins.fetchTree { type = "github"; }' uses `{ owner, repo }'.
      ( ( x.type or null ) == "github" -> ( x ? owner ) && ( x ? repo ) )
      # Everything else requires a URL.
      ( ( x.type or null ) != "github" -> x ? url )
      # Require purifying info when `pure == true'.
      ( pure && ( builtins.elem ( x.type or null ) ["github" "git"] )
        ->
        ( x ? rev ) || ( x ? hash.narHash ) ||
        ( ( x.type == "github" ) && ( x ? ref ) ) )
      # `builtins.fetchGit' requires `rev' in pure mode.
      ( pure && ( ! ( x ? type ) ) -> ( x ? hash ) || ( x ? rev ) )
    ];
    tname = "fetchInfo:generic:git:${if pure then "" else "im"}pure";
    cond = x: ( checkPresent x ) && ( minimal x );
  in yt.restrict tname cond ( yt.attrs yt.any );


  genericGitArgsPure   = genericGitArgs' true;
  genericGitArgsImpure = genericGitArgs' false;


# ---------------------------------------------------------------------------- #

in {
  inherit
    nixpkgsFetchgitArgs
    genericGitArgFields
    genericGitArgs'
    genericGitArgsPure
    genericGitArgsImpure
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
