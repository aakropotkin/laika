# ============================================================================ #
#
# General tests for `fetchTarball' and wrappers.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  lodash_tarball_sourceInfo = {
    outPath = "/nix/store/x3m3q3wv4w3xqs6bmngmmxqb1hng138z-source";
    narHash = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
  };

  tests = {

# ---------------------------------------------------------------------------- #

    testFetchTarball_0 = {
      # Lodash Tarball SourceInfo
      expr = lib.libfetch.fetchTarballW {
        url     = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
        sha256  = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
      };
      expected = lodash_tarball_sourceInfo.outPath;
    };


# ---------------------------------------------------------------------------- #

    testFetchTarball_1 = {
      # Lodash Tarball SourceInfo
      expr = if lib.inPureEvalMode then null else
        lib.libfetch.fetchTarballW
          "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
      expected = if lib.inPureEvalMode then null else
                 lodash_tarball_sourceInfo.outPath;
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
