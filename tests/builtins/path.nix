# ============================================================================ #
#
# General tests for `fetchGit' and wrappers.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  inherit (lib.libfetch) pathW;

# ---------------------------------------------------------------------------- #

  tests = {

# ---------------------------------------------------------------------------- #

    testPathW_0 = {
      # Lodash Git SourceInfo
      expr     = builtins.isString ( pathW { path = toString ./.; } );
      expected = true;
    };


# ---------------------------------------------------------------------------- #

  };  # End Tests


# ---------------------------------------------------------------------------- #

in tests


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #