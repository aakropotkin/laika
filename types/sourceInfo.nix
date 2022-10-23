# ============================================================================ #
#
# TODO: Specialize based on `fetchTree { type = <TYPE>; }'.
#
# ---------------------------------------------------------------------------- #

{ ytypes }: let

  inherit (ytypes.Core) eitherN restrict struct option;
  inherit (ytypes.Prim) string bool int;
  inherit (ytypes) Hash FS Git;

# ---------------------------------------------------------------------------- #



# ---------------------------------------------------------------------------- #

  Structs = let
    # `sourceInfo' fields by type as produced by `builtins.fetchTree' and
    # other builtin fetchers.
    siFields = {
      outPath = FS.store_path;
      narHash = Hash.Strings.sha256_sri;
      # Git/Github/Path/Mercurial/Sourcehut
      lastModified     = int;
      lastModifiedDate = ytypes.Strings.timestamp;
      # Git/Github/Mercurial/Sourcehut
      rev      = Git.rev;
      shortRev = string;
      # Git/Mercurial
      revCount   = int;
      # Git
      submodules = bool;
    };
  in {

    # The most detailed record.
    git = struct "sourceInfo:git" siFields;

    github = struct "sourceInfo:github" {
      inherit (siFields)
        outPath narHash lastModified lastModifiedDate rev shortRev
      ;
    };

    sourcehut = struct "sourceInfo:sourcehut" {
      inherit (siFields)
        outPath narHash lastModified lastModifiedDate rev shortRev
      ;
    };

    # You need to install `nix profile install nixpkgs#mercurial' first.
    # builtins.fetchTree { url = "https://www.mercurial-scm.org/repo/hello"; type = "hg"; }
    mercurial = struct "sourceInfo:mercurial" {
      inherit (siFields)
        outPath narHash rev revCount shortRev
      ;
    };

    path = struct "sourceInfo:path" {
      inherit (siFields) outPath narHash lastModified lastModifiedDate;
    };

    file = struct "sourceInfo:file" {
      inherit (siFields) outPath narHash;
    };

    # Same as `file'.
    tarball = struct "sourceInfo:tarball" {
      inherit (siFields) outPath narHash;
    };

  };  # End Structs


# ---------------------------------------------------------------------------- #

  Eithers = {

    sourceInfo = ( eitherN [
      Structs.git
      Structs.github
      Structs.sourcehut
      Structs.mercurial
      Structs.path
      Structs.file
      Structs.tarball
    ] ) // {
      name    = "sourceInfo";
      toError = v: result: let
        pv = ytypes.__internal.prettyPrint v;
        common = "Expected a sourceInfo struct " +
                 "(git|github|sourcehut|mercurial|path|file|tarball), ";
        wrongType = "but value '${pv}' is of type '${builtins.typeOf v}'.";
        notSI = "but value '${pv}' does not align with any sourceInfo schema.";
        why = if ! ( builtins.isAttrs v ) then wrongType else notSI;
      in common + why;
    };

    indirect = Eithers.sourceInfo;

  };


# ---------------------------------------------------------------------------- #

in {
  inherit Structs Eithers;
  inherit (Structs)
    git
    github
    sourcehut
    mercurial
    path
    file
    tarball
  ;
  inherit (Eithers)
    sourceInfo
    indirect
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
