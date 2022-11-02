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
      };
    };

  };

in {
  inherit tests;
}
