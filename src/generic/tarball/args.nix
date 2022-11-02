# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  yt  = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;

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

  # This super-set can support any tarball/file fetcher.
  genericTarballArgs = {
    name  = yt.FS.Strings.filename;
    type  = yt.enum ["file" "tarball"];
    url   = yt.Uri.Strings.uri_ref;
    flake = yt.option yt.bool;
    inherit (yt.Hash.Sums) hash;
    unpack     = yt.option yt.bool;
    executable = yt.option yt.bool;
  };


# ---------------------------------------------------------------------------- #

in {
  inherit
    nixpkgsFetchurlArgs
    nixpkgsFetchzipArgs
    builtinsFetchTarballArgs
    builtinsFetchurlArgs
    genericTarballArgs
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
