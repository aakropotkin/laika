# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

# ---------------------------------------------------------------------------- #

 nt = lib.types;
 lt = { inherit (lib.liblaika) inputScheme uri rev tree input relpath; };


# ---------------------------------------------------------------------------- #

 # TODO: audit fields.
 mkInput = attrs: {
   config = {
     inherit attrs;
     schemeName = config.name;
     scheme     = config;
     functor    = {
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
      pretty = builtins.unsafeDiscardStringContext url;
      pa     = let
        keep = builtins.intersectAttrs {
          rev = true; ref = true; host = true;
        } ps;
        bads = builtins.attrNames ( removeAttrs ps ["rev" "ref" "host"] );
        msg  = "URL '" + pretty + "' has unsupported paramter(s): " +
               ( builtins.concatStringsSep " " bads );
      in if bads == [] then keep else throw msg;
      extra = let
        both   = builtins.interSectAttrs rr pa;
        msgRev = "URL '" + pretty + "' contains multiple commit hashes";
        msgRef = "URL '" + pretty + "' contains multiple branch/tag names";
        msg    = let
          msgs = ( if both ? rev then [msgRev] else [] ) ++
                 ( if both ? ref then [msgRef] else [] );
        in builtins.concatStringsSep "\n" msgs;
      in if both == {} then rr // pa else throw msg;
      attrs = extra // {
        type  = builtins.head m;
        owner = builtins.elemAt m 1;
        owner = builtins.elemAt m 2;
      };
      rsl = mkInput attrs;
    in builtins.addErrorContext ( "Parsing URL '" + pretty + "'" ) rsl;


    inputFromAttrs = attrs: let
      pretty = lib.generators.toPretty { multiline = false; } attrs;
      allow  = [
        "type" "owner" "repo" "ref" "rev" "narHash" "lastModified" "host"
      ];
      bads = builtins.attrNames ( removeAttrs attrs allow );
      msg  = "Input '${pretty}' has unsupported attr(s): " +
             ( builtins.concatStringsSep " " bads );
      rsl = if bads == [] then mkInput attrs else throw msg;
    in builtins.addErrorContext ( "Processing input attrs '" + pretty + "'" )
       rsl;


    toURL = input: let
      base =
        input.attrs.type + ":" + input.attrs.owner + "/" + input.attrs.repo;
      rr = let
        r = input.attrs.rev or input.attrs.ref or null;
      in if r == null then "/" else "/" + r;
      params = builtins.intersectAttrs {
        narHash = true; host = true; lastModified = true;
      } input.attrs;
      ps = let
        proc = name: value:
          if value == null then name else name + "=" + ( toString value );
        strs   = builtins.mapAttrs proc params;
        joined = builtins.concatStringsSep "&" ( builtins.attrValues strs );
      in if params == {} then "" else "?" + joined;
      pretty = lib.generators.toPretty { multiline = false; } input.attrs;
      rsl = base + ps;
    in builtins.addErrorContext (
      "Converting input '" + pretty + "' to a URL string"
    ) rsl;


    applyOverrides = { input, rev ? null, ref ? null }: let
      nr = removeAttrs input.attrs ["rev" "ref"];
      rr = if rev != null then { inherit rev; } else { inherit ref; };
    in if ( rev == null ) && ( ref == null ) then input else
       input // { attrs = nr // rr; };


    fetch = input: let
      src = builtins.fetchTree input.attrs;
    in {
      tree.storePath = src.outPath;
      input = ( removeAttrs input.attrs ["rev" "ref"] ) // {
        inherit (src) rev narHash lastModified;
      };
    };


  };  /* End `config' */


}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
