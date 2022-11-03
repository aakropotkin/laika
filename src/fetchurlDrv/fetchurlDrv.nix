# ============================================================================ #
#
# fetchurlDrvW
#
# ---------------------------------------------------------------------------- #

{ lib
, typecheck   ? false
, fetchurlDrv ? import ./fetchurlDrvUnwrapped.nix
}: let

  yt = lib.ytypes // lib.ytypes.Prim // lib.ytypes.Core;
  inherit (yt) option struct bool;

# ---------------------------------------------------------------------------- #

  fetchurlDrvW = {

    __functionMeta = {
      name      = "fetchurlDrvW";
      from      = "laika#lib.libfetch";
      innerName = "fetchurlDrv";

      signature = let
        hash = yt.eitherN [
          yt.Hash.md5 yt.Hash.sha1 yt.Hash.sha256 yt.Hash.sha512
        ];
        hashAlgos = yt.enum ["" "sha1" "md5" "sha256" "sha512"];
        arg1_rough = struct {
          url            = yt.Uri.Strings.uri_ref;
          name           = option yt.FS.filename;  # FIXME: storepath filename
          hash           = option hash;
          md5            = option yt.Hash.md5;
          sha1           = option yt.Hash.sha1;
          sha256         = option yt.Hash.sha256;
          sha512         = option yt.Hash.sha512;
          outputHash     = option hash;
          outputHashAlgo = option hashAlgos;
          executable     = option bool;
          unpack         = option bool;
          extraAttrs     = option ( yt.attrs yt.any );
          extraDrvAttrs  = option ( yt.attrs yt.any );
        };
        arg1 = let
          # Require at least one hash arg.
          cond = x: builtins.any ( f: x ? ${f} ) [
            "hash" "sha1" "md5" "sha256" "sha512" "outputHash"
          ];
        in yt.restrict "locked" cond arg1_rough;
      in [arg1 yt.drv];

      properties = {
        inherit typecheck;
        pure    = true;
        builtin = true;
        family  = "file";
      };
    };

    __functionArgs = {
      url            = false;
      name           = true;   # Defaults to "source". XXX: docs are wrong.
      hash           = true;
      md5            = true;
      sha1           = true;
      sha256         = true;
      sha512         = true;
      outputHash     = true;
      outputHashAlgo = true;
      executable     = true;
      unpack         = true;
      extraAttrs     = true;
      extraDrvAttrs  = true;
    };

    __innerFunction = fetchurlDrv;

    # Stashed "auto-args" that can be set by users.
    __thunk = {
      unpack     = false;
      executable = false;
    };

    __processArgs = self: x: let
      args = if builtins.isString x then { url = x; } else x;
    in self.__thunk // args;

    # Typechecking is performed after `__processArgs'.
    # This allows users to extend `__processArgs' with shims more easily.
    __functor = self: x: let
      checked = yt.defun self.__functionMeta.signature self.__innerFunction;
      fn      = if typecheck then checked else self.__innerFunction;
    in fn ( self.__processArgs self x );

  };


# ---------------------------------------------------------------------------- #

in fetchurlDrvW


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
