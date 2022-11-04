{ lib }: let

  tests = {

    # XXX: Doesn't work for `github.com:<USER>'
    testParseGitUrl_0 = {
      expr = lib.libfetch.parseGitUrl "git+ssh://git@github.com/aakropotkin/rime.git#95aeaf83c247b8f5aa561684317ecd860476fcd6";
      expected = {
        host = "github.com";
        owner = "aakropotkin";
        repo = "rime";
        rev = "95aeaf83c247b8f5aa561684317ecd860476fcd6";
        transport = "ssh";
        type = "git";
        url = "git+ssh://git@github.com/aakropotkin/rime.git#95aeaf83c247b8f5aa561684317ecd860476fcd6";
        user = "git";
        ref  = null;
      };
    };

    testParseGitUrl_1 = let
      base = "https://code.tvl.fyi/depot.git";
      ref  = "refs/heads/canon";
      rev  = "57cf952ea98db70fcf50ec31e1c1057562b0a1df";
    in {
      expr     = lib.libfetch.parseGitUrl "${base}?rev=${rev}&ref=${ref}";
      expected = {
        host = "code.tvl.fyi";
        owner = null;
        repo = "depot";
        inherit rev ref;
        transport = "https";
        type = "git";
        url  = "${base}?rev=${rev}&ref=${ref}";
        user = null;
      };
    };

    testGenericTarballArgs_0 = {
      expr = lib.libfetch.asGenericTarballArgsPure {
        type = "tarball";
        url  = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
        # narHash
        hash = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
      };
      expected = {
        type = "tarball";
        url  = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
        hash       = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
        narHash    = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
        sha        = "amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
        executable = false;
        flake      = false;
        unpack        = true;
        recursive     = true;
        recursiveHash = true;
      };
    };

    testGenericFileArgs_0 = {
      expr = lib.libfetch.asGenericFileArgsPure {
        url  = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
        # narHash
        sha256 = "sha256-fn2qMkL7ePPYQyW/x9nvDOl05BDrC7VsfvyfW0xkQyE=";
      };
      expected = {
        type = "file";
        url  = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
        hash       = "sha256-fn2qMkL7ePPYQyW/x9nvDOl05BDrC7VsfvyfW0xkQyE=";
        narHash    = "sha256-fn2qMkL7ePPYQyW/x9nvDOl05BDrC7VsfvyfW0xkQyE=";
        sha        = "fn2qMkL7ePPYQyW/x9nvDOl05BDrC7VsfvyfW0xkQyE=";
        executable = false;
        flake      = false;
        unpack        = false;
        recursive     = false;
        recursiveHash = false;
      };
    };

    testGenericUrlArgs_0 = {
      expr = lib.libfetch.asGenericUrlArgsPure {
        unpack = false;
        url  = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
        # narHash
        sha256 = "sha256-fn2qMkL7ePPYQyW/x9nvDOl05BDrC7VsfvyfW0xkQyE=";
      };
      expected = {
        type    = "file";
        url     = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
        hash    = "sha256-fn2qMkL7ePPYQyW/x9nvDOl05BDrC7VsfvyfW0xkQyE=";
        narHash = "sha256-fn2qMkL7ePPYQyW/x9nvDOl05BDrC7VsfvyfW0xkQyE=";
        sha     = "fn2qMkL7ePPYQyW/x9nvDOl05BDrC7VsfvyfW0xkQyE=";
        executable    = false;
        flake         = false;
        unpack        = false;
        recursive     = false;
        recursiveHash = false;
      };
    };

  };  # End tests

in {
  inherit tests;
}
