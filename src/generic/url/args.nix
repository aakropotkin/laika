# ============================================================================ #
#
# File/Tarball fetching args.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  yt  = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;

# ---------------------------------------------------------------------------- #

  hashFields = {
    inherit (yt.Hash)
      narHash md5 sha1 sha256 sha512
      shasum     # Alias of sha1
      integrity  # Any SRI
      hash       # Any
      # b16      # non-SRI base16 hash of any 4 algos
    ;
    inherit (yt.Hash.Strings)
      sha256_sri  sha512_sri  sha1_sri  md5_sri
      sha256_hash sha512_hash sha1_hash md5_hash
    ;
  };


# ---------------------------------------------------------------------------- #

  # Tarball Fetcher Argsets.

  nixpkgsFetchurlArgs = {
    name          = true;   # defaults to url basename
    url           = false;  # real one is optional but only with `urls = [...]'
    executable    = true;
    recursiveHash = true;   # for a single file choose "false"
    # One of the following
    sha1          = true;
    sha256        = true;
    sha512        = true;
    hash          = true;
    md5           = true;
    # ...
  };

  nixpkgsFetchzipArgs      = { url = false; sha256 = false; };
  builtinsFetchTarballArgs = { url = false; sha256 = false; };
  # XXX: accepts as a string not an attrset.
  builtinsFetchurlArgs = { url = false; };


# ---------------------------------------------------------------------------- #

  # This super-set can support any tarball/file fetcher.
  genericUrlArgFields = {
    name       = yt.FS.Strings.filename;
    type       = yt.enum ["file" "tarball"];
    url        = yt.Uri.Strings.uri_ref;
    flake      = yt.bool;
    unpack     = yt.option yt.bool;
    executable = yt.option yt.bool;
    inherit (hashFields)
      narHash integrity hash shasum sha1 sha256 sha512
    ;
  };


# ---------------------------------------------------------------------------- #

  # If unspecified don't attempt to unpack.
  asGenericUrlArgs' = pure: {
    url
  , name       ? "source"
  , type       ? if ( args.unpack or false ) then "tarball" else "file"
  , flake      ? false
  , unpack     ? ( args.type or "file" ) == "tarball"
  , executable ? false
  , recursive  ? args.recursiveHash or ( unpack || executable )

  , hash ? builtins.foldl' ( a: b: if a != "" then a else b ) "" [
    integrity md5 sha1 sha256 sha512
  ]
  , integrity ? args.narHash or args.sha256_sri or args.sha512_sri or
                args.sha1_sri or args.md5_sri or ""
  , narHash   ? sha256
  , md5       ? args.md5_sri    or args.md5_hash    or ""
  , sha1      ? args.shasum     or args.sha1_sri    or args.sha1_hash or ""
  , sha256    ? args.narHash    or args.sha256_sri  or args.sha256_hash or ""
  , sha512    ? args.sha512_sri or args.sha512_hash or ""

  # Just here for `lib.functionArgs'
  , shasum      ? sha1
  , md5_sri     ? ""
  , sha1_sri    ? ""
  , sha256_sri  ? ""
  , sha512_sri  ? ""
  , md5_hash    ? ""
  , sha1_hash   ? ""
  , sha256_hash ? ""
  , sha512_hash ? ""
  , ...
  } @ args: let
    hashes' = lib.filterAttrs ( _: x: x != "" ) {
      inherit narHash md5 sha1 sha256 sha512;
      # Convert a b64 SRI string -> b64 hash string...
      # XXX: Okay I swear I can explain. I know this looks really stupid.
      # There's an unspecified behavior in the `builtins:fetchurl' derivation
      # internals that causes it to throw an error if the `hash' argument starts
      # with an algo "SRI" style prefix - but it is perfectly capable of
      # converting b64 -> b16 on its own if you remove the prefix for it.
      #
      # Sure, it would make way more sense if it just did this on its own, but
      # I don't make the rules I'm just playing by them.
      hash = let
        m = builtins.match "(md5|sha(1|256|512))-(.*)" hash;
      in if m == null then hash else builtins.elemAt m 2;
      integrity = if ( integrity != "" ) || ( hash == "" ) then integrity else
                  lib.libenc.hexToSri hash;
    };
    loc = "laika#lib.libfetch#genericTarballArgsPure";
    hashes = if ( hashes' != {} ) || ( ! pure ) then hashes' else
             throw "(${loc}): No hash arg provided";
    explicit = ( if args ? name then { inherit name; } else {} ) //
               ( if args ? executable then { inherit executable; } else {} );
  in hashes // {
    inherit url type flake unpack executable recursive;
    recursiveHash = recursive;
  };

  asGenericUrlArgsPure   = asGenericUrlArgs' true;
  asGenericUrlArgsImpure = asGenericUrlArgs' false;


# ---------------------------------------------------------------------------- #

  asGenericFileArgs' = pure: {
    __functionArgs = let
      fa = lib.functionArgs ( asGenericUrlArgs' pure );
    in removeAttrs fa ["unpack" "recursive" "type"];
    __innerFunction = args: let
      fa = args // { type = "file"; unpack = false; recursive = false; };
      fu = asGenericUrlArgs' pure fa;
    in removeAttrs fu ["unpack" "recursive"];
    __functor = self: x: self.__innerFunction x;
  };
  asGenericFileArgsPure   = asGenericFileArgs' true;
  asGenericFileArgsImpure = asGenericFileArgs' false;


# ---------------------------------------------------------------------------- #

  asGenericTarballArgs' = pure: {
    __functionArgs = let
      fa = lib.functionArgs ( asGenericUrlArgs' pure );
    in removeAttrs fa ["unpack" "recursive" "type"];
    __innerFunction = args: let
      fa = args // { type = "tarball"; unpack = true; recursive = true; };
      fu = asGenericUrlArgs' pure fa;
    in removeAttrs fu ["unpack" "recursive"];
    __functor = self: x: self.__innerFunction x;
  };
  asGenericTarballArgsPure   = asGenericTarballArgs' true;
  asGenericTarballArgsImpure = asGenericTarballArgs' false;


# ---------------------------------------------------------------------------- #

in {
  inherit
    nixpkgsFetchurlArgs
    nixpkgsFetchzipArgs
    builtinsFetchTarballArgs
    builtinsFetchurlArgs
    genericUrlArgFields
    asGenericUrlArgs'     asGenericUrlArgsPure     asGenericUrlArgsImpure
    asGenericFileArgs'    asGenericFileArgsPure    asGenericFileArgsImpure
    asGenericTarballArgs' asGenericTarballArgsPure asGenericTarballArgsImpure
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
