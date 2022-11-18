# ============================================================================ #
#
# General tests for YANTS types.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  inherit (lib.ytypes) SourceInfo;

# ---------------------------------------------------------------------------- #

  lodash_git_sourceInfo = {
    lastModified     = 1666556950;
    lastModifiedDate = "20221023202910";
    narHash    = "sha256-H3BjwgbA0LPrCwDMYtZu7q1r9rWBQcAon1y1glKgtrk=";
    outPath    = "/nix/store/dx5fy4dwy2s475jabrxg2n2imqn2xni3-source";
    rev        = "51e1d2da76b5b5718022f104c2a0782323b8c792";
    revCount   = 110;
    shortRev   = "51e1d2d";
    submodules = false;
  };

  tests = {

# ---------------------------------------------------------------------------- #

    testSourceInfo_0 = {
      # Lodash Git SourceInfo
      expr = SourceInfo.source_info.check lodash_git_sourceInfo;
      expected = true;
    };


# ---------------------------------------------------------------------------- #

    testSourceInfo_git_0 = {
      # Lodash Git SourceInfo
      expr = SourceInfo.git.check lodash_git_sourceInfo;
      expected = true;
    };


# ---------------------------------------------------------------------------- #

    testSourceInfo_github_0 = {
      # Lodash Git SourceInfo
      expr = SourceInfo.github.check lodash_git_sourceInfo;
      expected = false;
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
