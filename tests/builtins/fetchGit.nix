# ============================================================================ #
#
# General tests for `fetchGit' and wrappers.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  inherit (lib.ytypes) SourceInfo;

# ---------------------------------------------------------------------------- #

  lodash_git_sourceInfo = {
    lastModified = 1619198737;
    lastModifiedDate = "20210423172537";
    narHash = "sha256-9qUKLWumnPxZU0rDNtKjZUdSKGDQIqtEVLv4cfwPPnw=";
    outPath = "/nix/store/ah3r84xzpq6mvr0sz3yzbflydwmzfvn8-source";
    rev = "2da024c3b4f9947a48517639de7560457cd4ec6c";
    revCount = 8005;
    shortRev = "2da024c";
    submodules = false;
  };

  tests = {

# ---------------------------------------------------------------------------- #

    testFetchGit_0 = {
      # Lodash Git SourceInfo
      expr = lib.libfetch.fetchGitW {
        url = "https://github.com/lodash/lodash.git";
        rev = "2da024c3b4f9947a48517639de7560457cd4ec6c";
      };
      expected = lodash_git_sourceInfo;
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
