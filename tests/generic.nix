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

  };

in {
  inherit tests;
}
