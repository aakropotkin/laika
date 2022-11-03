# ============================================================================ #
#
# FIXME: you just dumped this from `at-node-nix' but haven't rewritten.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  yt  = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;

# ---------------------------------------------------------------------------- #

  # Fetch a tarball using the given hash, and then unpack.
  # This allows you to use the "packed" hash but still return a store-path to
  # an unpacked tarball.

  fetchurlDrvUnpackAfter = {};

# ---------------------------------------------------------------------------- #

  # Wraps `fetchurlDrv'.
  # Since it isn't technically a builtin this wrapper is really just for
  # consistency with the other wrappers.
  #
  # NOTE: You can't avoid unpacking in a platform dependant way in pure mode;
  # with that in mind the best we can do is fetch the tarball and pass a message
  # for builders to handle later.
  # We add the field `needsUpack = true' in pure mode.
  # In practice the best thing to do is to override this fetcher in pure mode
  # in your config.
  fetchurlDrvUnpackAfterW = {
    #__functionArgs = hashFields // { name = true; url = false; };
    __functionArgs = ( lib.functionArgs lib.libfetch.fetchurlDrvW ) // {
      unpackAfter = true;  # Allows acting as a `tarballFetcher' in pure mode.
      resolved    = true;
      integritry  = true;
      sha1        = true;
    };

    __thunk = {
      unpack           = false;
      unpackAfter      = false;
      allowSubstitutes = true;
    };

    __innerFunction = lib.libfetch.fetchurlDrvW;

    __processArgs = self: x: let
      rough  = x // {
        url  = x.url or x.resolved;
        hash = x.hash or x.integrity or x.sha1 or x.narHash or x.sha256 or null;
      };
      args = if rough.hash != null then rough else removeAttrs rough ["hash"];
      args' = removeAttrs ( self.__thunk // args ) ["unpackAfter"];
    in builtins.intersectAttrs self.__functionArgs args';

    # Call inner without `unpackAfter' arg, preserving it as a tag in our result
    __functor = self: args: let
      fetched = self.__innerFunction ( self.__processArgs self args );
      # Unpack
      unpacked      = builtins.fetchTarball { url = fetched.outPath; };
      unpackedFull  = unpacked // { passthru.tarball = fetched; };
      doUnpackAfter = args.unpackAfter or self.__thunk.unpackAfter;
    in if doUnpackAfter then unpackedFull else fetched;
  };


# ---------------------------------------------------------------------------- #

in {
  inherit
    fetchurlDrvUnpackAfter
    fetchurlDrvUnpackAfterW
  ;
}

# ---------------------------------------------------------------------------- #
