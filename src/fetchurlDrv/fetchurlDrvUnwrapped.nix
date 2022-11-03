# ============================================================================ #
#
# Yanked from Nix's internal `src/libexpr/fetchurl.nix'.
# The only notable change is we don't support `impure' here.
#
# This is the unwrapped form.
# See `./fetchurlDrv.nix' for the typed wrapper.
#
# ---------------------------------------------------------------------------- #

let

# ---------------------------------------------------------------------------- #

  dropArExt = n: let
    tarball_ext_p = "\\.(tar(\\.[gx]z)?|gz|tgz|zip|xz|bz(ip)?)";
    m = builtins.match "(.*)${tarball_ext_p}" n;
  in if m == null then n else builtins.head m;

# ---------------------------------------------------------------------------- #

in {
  url
, name ? let b = baseNameOf ( toString url );
         in if unpack then dropArExt b else b

, hash ? "" # an SRI hash
# Legacy hash specification
, md5    ? ""
, sha1   ? ""
, sha256 ? ""
, sha512 ? ""

, outputHash ?
    if hash   != "" then hash   else
    if sha512 != "" then sha512 else
    if sha1   != "" then sha1   else
    if md5    != "" then md5    else
    sha256

, outputHashAlgo ?
    if hash   != "" then ""       else
    if sha512 != "" then "sha512" else
    if sha1   != "" then "sha1"   else
    if md5    != "" then "md5"    else
    "sha256"

, executable    ? false  # may imply that we are fetching a directory
, unpack        ? false
, extraAttrs    ? {}
, extraDrvAttrs ? {}
}: derivation ( {

  inherit name url executable unpack outputHashAlgo outputHash;

  builder = "builtin:fetchurl";
  system  = "builtin";

  outputHashMode = if ( unpack || executable ) then "recursive" else "flat";

  # No need to double the amount of network traffic
  preferLocalBuild = true;

  impureEnvVars = [
    # We borrow these environment variables from the caller to allow
    # easy proxy configuration.
    # This is impure, but a fixed-output derivation like fetchurl is allowed to
    # do so since its result is by definition pure.
    "http_proxy" "https_proxy" "ftp_proxy" "all_proxy" "no_proxy"
  ];

  # To make "nix-prefetch-url" work.
  urls = [url];

} // extraDrvAttrs ) // extraAttrs


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
