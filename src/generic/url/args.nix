# ============================================================================ #
#
# File/Tarball fetching args.
#
# FIXME: we don't typecheck currently.
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
      # b16      # non-SRI base16 hash of any 4 algos
    ;
    inherit (yt.Hash.Strings)
      sha256_sri  sha512_sri  sha1_sri  md5_sri
      sha256_hash sha512_hash sha1_hash md5_hash
    ;
    hash = yt.Hash.integrity;
    # Non-SRI SHA of any encoding.
    # This is dumb but `builtins:fetchurl' cares for some reason.
    sha  = yt.eitherN [
      yt.Hash.Strings.md5_hash
      yt.Hash.Strings.sha1_hash
      yt.Hash.Strings.sha256_hash
      yt.Hash.Strings.sha512_hash
    ];
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
  builtinsFetchurlArgs0 = { url = false; };

  # sha256 depends on purity.
  builtinsFetchurlArgs1 = { url = false; sha256 = true; name = true; };

  builtinsFetchTreeUrlArgs = { type = "false"; };


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
      narHash integrity hash shasum sha1 sha256 sha512 sha
    ;
  };


# ---------------------------------------------------------------------------- #

  # If unspecified don't attempt to unpack.
  # XXX: The hash conversions here are useful enough to become their own
  # dedicated routine.
  # NOTE: `ak-nix#lib.libenc.sriToHex' also exists if we need it; but AFAIK
  # all of the builtins are able to accept sha256 SRI.
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
  , sha       ? args.md5_hash or args.sha1_hash or args.sha256_hash or
                args.sha512_hash or ""

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
  , recursiveHash ? recursive
  , ...
  } @ args: let
    maybeStripSRI = h: let
      m = builtins.match "(md5|sha(1|256|512))-(.*)" h;
    in if m == null then h else builtins.elemAt m 2;
    coerceSRI = h:
      if h == "" then "" else
      if lib.ytypes.Hash.integrity.check h then h else
      lib.libenc.hexToSri h;
    hashes' = lib.filterAttrs ( _: x: x != "" ) {
      # Convert a b64 SRI string -> bare b64 SHA.
      # XXX: Okay I swear I can explain. I know this looks really stupid.
      # There's an unspecified behavior in the `builtins:fetchurl' derivation
      # internals that causes it to throw an error if the `hash' argument starts
      # with an algo "SRI" style prefix - but it is perfectly capable of
      # converting b64 -> b16 on its own if you remove the prefix for it.
      #
      # Sure, it would make way more sense if it just did this on its own, but
      # I don't make the rules I'm just playing by them.
      sha = args.sha or ( maybeStripSRI hash );
      # Convert to SRI ( for `builtins:fetchurl' derivation )
      hash = if lib.ytypes.Hash.integrity.check hash then hash else
             if ( integrity != "" ) then integrity else
             coerceSRI hash;
      narHash = if narHash != "" then narHash else
                if lib.ytypes.Hash.sha256.check integrity then integrity else
                if lib.ytypes.Hash.sha256.check hash then coerceSRI hash else
                "";
    };
    loc = "laika#lib.libfetch#genericTarballArgsPure";
    hashes = if ( hashes' != {} ) || ( ! pure ) then hashes' else
             throw "(${loc}): No hash arg provided";
    explicit = ( if args ? name then { inherit name; } else {} ) //
               ( if args ? executable then { inherit executable; } else {} );
  in hashes // {
    inherit url type flake unpack executable recursive recursiveHash;
  };

  asGenericUrlArgsPure   = asGenericUrlArgs' true;
  asGenericUrlArgsImpure = asGenericUrlArgs' false;


# ---------------------------------------------------------------------------- #

  asGenericFileArgs' = pure: {
    __functionArgs = let
      fa = lib.functionArgs ( asGenericUrlArgs' pure );
    in removeAttrs fa ["unpack" "recursive" "recursiveHash" "type"];
    __innerFunction = args: let
      fa = args // { type = "file"; unpack = false; recursive = false; };
      fu = asGenericUrlArgs' pure fa;
    in removeAttrs fu ["unpack" "recursive" "recursiveHash"];
    __functor = self: x: self.__innerFunction x;
  };
  asGenericFileArgsPure   = asGenericFileArgs' true;
  asGenericFileArgsImpure = asGenericFileArgs' false;


# ---------------------------------------------------------------------------- #

  asGenericTarballArgs' = pure: {
    __functionArgs = let
      fa = lib.functionArgs ( asGenericUrlArgs' pure );
    in removeAttrs fa ["unpack" "recursive" "recursiveHash" "type"];
    __innerFunction = args: let
      fa = args // { type = "tarball"; unpack = true; recursive = true; };
      fu = asGenericUrlArgs' pure fa;
    in removeAttrs fu ["unpack" "recursive" "recursiveHash"];
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
    genericUrlArgFields
    asGenericUrlArgs'     asGenericUrlArgsPure     asGenericUrlArgsImpure
    asGenericFileArgs'    asGenericFileArgsPure    asGenericFileArgsImpure
    asGenericTarballArgs' asGenericTarballArgsPure asGenericTarballArgsImpure
  ;
    builtinsFetchurlArgs = builtinsFetchurlArgs1;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
