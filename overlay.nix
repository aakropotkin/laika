final: prev: {
  lib = prev.lib.extend ( _: libPrev: {
    ytypes = libPrev.ytypes.extend ( import ./types/overlay.yt.nix );
  } );
}
