# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  # FIXME: move to `rime'.
  isGithubUrl = url:
    lib.test "([^@]+@)?github\\.com" ( lib.liburi.parseFullUrl url ).authority;

  # FIXME: doesn't handle `git+ssh://git@github.com:<USER>/<REPO>'.
  # You have to use "git+ssh://git@github.com/<USER>/<REPO>".
  parseGitUrl = {
    __functionArgs.url = false;
    __innerFunction = { url }: let
      parsed = lib.liburi.parseFullUrl url;
      hp     = lib.liburi.parseServer parsed.authority;
      repo = let
        m = builtins.match "(.*)\\.git.*" ( baseNameOf parsed.path );
      in if m == null then baseNameOf parsed.path else builtins.head m;
    in {
      inherit repo url;
      inherit (parsed.scheme) transport;
      type = if baseNameOf hp.hostport == "github" then "github" else "git";
      user = hp.userinfo;
      host = hp.hostport;
      # XXX: There's a good chance you're going to bad results for any
      # non-github hosts; but there's no real use case for the `owner' field
      # outside of `github' so fuck it.
      owner = let
        s  = builtins.split "/${repo}\\.git" parsed.path;
        s0 = builtins.head s;
        d = if s0 == "" then dirOf parsed.path else s0;
      in baseNameOf d;
      # FIXME: I think flake-ref do `.../foo.git/<REV>?<QUERY>`
      rev = if parsed.fragment != null then parsed.fragment else
        if ( lib.test ".*rev=.*" parsed.query )
        then ( lib.liburi.parseQuery parsed.query ).rev
        else null;
      # FIXME: ref
    };
    __processArgs = self: x:
      if builtins.isString x then { url = x; } else {
        url = x.url or x.resolved;
      };
    __functor = self: args:
      self.__innerFunction ( self.__processArgs self args );
  };


# ---------------------------------------------------------------------------- #

in {
  inherit
    isGithubUrl
    parseGitUrl
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
