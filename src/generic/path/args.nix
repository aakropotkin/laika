# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib
, pure      ? lib.inPureEvalMode
, typecheck ? false
}: let

  yt  = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  plt = yt.NpmLock.Structs // yt.NpmLock;
  inherit (lib.libfetch) fetchTreeGithubW fetchTreeGitW fetchGitW;

# ---------------------------------------------------------------------------- #

  # name      = option yt.FS.Strings.filename;
  # path      = yt.FS.abspath;
  # filter    = option function;
  # recursive = option bool;
  # sha256    = option yt.Hash.sha256;
  builtinsPath = builtins.head lib.libfetch.pathW.signature;


   # type    = yt.enum ["path"];
   # path    = yt.FS.abspath;
   # narHash = if pure then yt.Hash.sha256_sri else
   #           option yt.Hash.sha256_sri;
   builtinsFetchTreePath = builtins.head lib.libfetch.fetchTreePathW.signature;

   # Either { type = "path"; path = "..."; } or { url = "path:..."; }
   flakeRefPath = yt.eitherN [yt.flakeRef.Strings.path_ref
                              yt.flakeRef.Structs.flake-ref-path];


# ---------------------------------------------------------------------------- #

  genericPathArgFields = {
    inherit (builtinsPath) name path filter;
    type      = yt.enum ["path"];
    flake     = yt.bool;
    url       = yt.FlakeRef.Strings.path_ref;
    recursive = yt.bool;
    sha256    = yt.Hash.sha256;
    narHash   = yt.Hash.sha256_sri;
    # I made these up
    basedir = yt.FS.abspath;
    inherit (yt.FS) relpath;
  };


# ---------------------------------------------------------------------------- #

  genericPathFetchFields = removeAttrs genericPath [
    "flake" "url" "basedir" "relpath"
  ];


# ---------------------------------------------------------------------------- #

  processGenericPathArgs = { __thunk ? {} } @ self: x: let
    path = let
      url     = if builtins.isString x then x else x.url;
      fromUrl = let
        m = builtins.match "(path(+file)?:)?(/.*)" url;
        p = builtins.elemAt m 2;
      in if m == null then url else if p == null then url else p;
      fromRel = let
        base = __thunk.basedir or
               ( throw "You must set basedir to fetch relative paths: ${rel}" );
        rel  = if builtins.isString x then fromUrl else x.relpath or fromUrl;
      in if lib.libpath.isAbspath rel then rel else
         lib.libpath.realpathRel' base rel;
    in fromRel;
    clean = if builtins.isString x then { inherit path; } else
            builtins.intersectAttrs genericPathFetchFields x;
    # FIXME: there's no attempt to detect the current hash style here.
    # We blindly assume SHA256 ::= hash at 16bit.
    hashes = {
      sha256  = x.sha256 or ( lib.yank "sha256-(.*)" x.narHash );
      narHash = x.narHash or ( lib.libenc.hexToSri x.sha256 );
    };
  in { type = "path"; } // clean // hashes;


# ---------------------------------------------------------------------------- #

in {
  inherit
    builtinsPath
    builtinsFetchTreePath
    flakeRefPath
    genericPathArgFields
    genericPathFetchFields
    processGenericPathArgs
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
