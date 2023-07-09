# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib
, config
, ...
}: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<laika>/schemes/interface.nix";

# ---------------------------------------------------------------------------- #

  options.schemes = lib.mkOption {
    type = nt.submodule {

      options.indirect = lib.mkOption {
        type = nt.deferredModule;
      };

      options.tarball = lib.mkOption {
        type = nt.deferredModule;
      };

      options.file = lib.mkOption {
        type = nt.deferredModule;
      };

      options.path = lib.mkOption {
        type = nt.deferredModule;
      };

      options.git = lib.mkOption {
        type = nt.deferredModule;
      };

      options.mercurial = lib.mkOption {
        type = nt.deferredModule;
      };

      options.github = lib.mkOption {
        type = nt.deferredModule;
      };

      options.gitlab = lib.mkOption {
        type = nt.deferredModule;
      };

      options.sourcehut = lib.mkOption {
        type = nt.deferredModule;
      };

    };
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
