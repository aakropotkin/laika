# ============================================================================ #
#
# General tests for `fetchurlDrv' and related wrappers.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  inherit (lib.libfetch)
    fetchurlDrv
    fetchurlDrvW
  ;

  lodashFetchInfo = {
    url    = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
    sha512 = "sha512-v2kDEe57lecTulaDIuNTPy3Ry4gLGJ6Z1O3vE1krg" +
             "XZNrsQ+LFTGHVxVjcXPs17LhbZVGedAJv8XZ1tvj5FvSg==";
  };


# ---------------------------------------------------------------------------- #

  tests = {

# ---------------------------------------------------------------------------- #

    testFetchurlDrvUnwrapped_0 = {
      expr = let
        tarball = fetchurlDrv lodashFetchInfo;
      in builtins.deepSeq tarball ( lib.isDerivation tarball );
      expected = true;
    };



# ---------------------------------------------------------------------------- #

  };  # End Tests


# ---------------------------------------------------------------------------- #

in tests


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
