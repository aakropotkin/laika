# ============================================================================ #
#
# General tests for `fetchTree' and wrappers.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  inherit (lib.ytypes) SourceInfo;
  inherit (lib.libfetch)
    fetchTreeGitW
    fetchTreeGithubW
  ;

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

  lodash_github_sourceInfo = removeAttrs lodash_git_sourceInfo [
    "submodules" "revCount"
  ];

  tests = {

# ---------------------------------------------------------------------------- #

    testFetchTreeGit_0 = {
      # Lodash Git SourceInfo
      expr = fetchTreeGitW {
        type = "git";
        url  = "https://github.com/lodash/lodash.git";
        rev  = "2da024c3b4f9947a48517639de7560457cd4ec6c";
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

    testFetchTreeGithub_0 = {
      # Lodash Git SourceInfo
      expr = fetchTreeGithubW {
        type  = "github";
        owner = "lodash";
        repo  = "lodash";
        rev   = "2da024c3b4f9947a48517639de7560457cd4ec6c";
      };
      expected = lodash_github_sourceInfo;
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
