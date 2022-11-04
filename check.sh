#! /usr/bin/env bash

set -eu;

: "${NIX_FLAGS:=-L --show-trace}";
: "${NIX:=nix}";
: "${SYSTEM:=$( $NIX eval --raw --impure --expr builtins.currentSystem; )}";
: "${GREP:=grep}";

nix_w() {
  { $NIX "$@" 3>&2 2>&1 1>&3|$GREP -v 'warning: unknown flake output'; }  \
    3>&2 2>&1 1>&3;
}

export NIX_CONFIG='
warn-dirty = false
';
#nix_w flake check $NIX_FLAGS;
#nix_w flake check $NIX_FLAGS --impure;
nix_w flake check $NIX_FLAGS --system "$SYSTEM";
nix_w flake check $NIX_FLAGS --system "$SYSTEM" --impure;
