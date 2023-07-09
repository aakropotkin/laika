final: prev: let
  ytypes      = import ./types/overlay.yt.nix;
  libfetchers = import ./src/overlay.lib.nix;
  liblaika    = import ./lib/overlay.lib.nix;
in {
  lib = ( ( prev.lib.extend ( _: libPrev: {
    ytypes = libPrev.ytypes.extend ytypes;
  } ) ).extend libfetchers ).extend liblaika;
}
