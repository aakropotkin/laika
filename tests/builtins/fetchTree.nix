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

    testFetchTreeGit_0 = {
      # Lodash Git SourceInfo
      expr = lib.libfetch.fetchTreeGitW {
        type = "git";
        url  = "https://github.com/lodash/lodash.git";
        rev  = "51e1d2da76b5b5718022f104c2a0782323b8c792";
      };
      expected = lodash_git_sourceInfo;
    };


# ---------------------------------------------------------------------------- #

    # FIXME: fetch a bogus repo where `narHash' will always work.
    # If `rev' ever changes it'll break, but what we care about is showing that
    # /technically/ you can just provide `narHash' if you wanted to.

    #testFetchTreeGit_1 = {
    #  # Lodash Git SourceInfo
    #  expr = lib.libfetch.fetchTreeGitW {
    #    type = "git";
    #    url  = "https://github.com/lodash/lodash.git";
    #    inherit (lodash_git_sourceInfo) narHash;
    #  };
    #  expected = lodash_git_sourceInfo;
    #};


# ---------------------------------------------------------------------------- #

  };  # End Tests


# ---------------------------------------------------------------------------- #

in tests


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
