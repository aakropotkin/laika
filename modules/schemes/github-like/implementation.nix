# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

# ---------------------------------------------------------------------------- #

 nt = lib.types;
 lt = {
   inherit (lib.liblaika) inputScheme uri rev tree input relpath;
 };


# ---------------------------------------------------------------------------- #

 mkInput = attrs: {
   config = {
     inherit (config) schemeName;
     inherit attrs;
     scheme  = config;
     functor = {
       fromURL   = self: self.scheme.fromURL;
       fromAttrs = self: self.scheme.fromAttrs;
       toURL     = self: self.scheme.toURL;
       toAttrs   = self: self.scheme.toAttrs;
     };
   };
 };


# ---------------------------------------------------------------------------- #

in {

  _file = "<laika>/schemes/github-like/implementation.nix";

  config = {

    name = lib.mkDefault "github";

    inputFromURL = url: let
      m  = builtins.match "([^:]+):([^?/]+)/([^?/]+)(/([^?]+))?(\\?(.*))?" url;
      rr = let
        r = builtins.elemAt m 4;
      in if rr == null then {} else
        if ( builtins.match "[[0-9a-fA-F]]{40}" r ) != null
        then { rev = r; }
        else { ref = r; };
      ps = let
        s    = builtins.elemAt m 6;
        proc = acc: e: let
          kv = builtins.match "([^=]+)=(.*)" e;
        in if builtins.isList e then acc else acc ++ [(
           if kv == null then { name = e; value = null; } else {
             name = builtins.head kv; value = builtins.elemAt kv 1;
           } )];
      in if builtins.elem s [null "" "?"] then {} else
        builtins.listToAttrs ( builtins.foldl' [] ( builtins.split "&" s ) );
      pa = builtins.intersectAttrs {
        rev = true; ref = true; host = true;
      } ps;
      extra = let
        both   = builtins.interSectAttrs rr pa;
        msgRev = "URL '${url}' contains multiple commit hashes";
        msgRef = "URL '${url}' contains multiple branch/tag names";
        msg    = let
          msgs = ( if both ? rev then [msgRev] else [] ) ++
                 ( if both ? ref then [msgRef] else [] );
        in builtins.concatStringsSep "\n" msgs;
      in if both == {} then rr // pa else throw msg;
    in extra // {
      type  = builtins.head m;
      owner = builtins.elemAt m 1;
      owner = builtins.elemAt m 2;
    };

  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
