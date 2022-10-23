# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ ytypes }: let

  inherit (ytypes.Core) restrict struct option;
  inherit (ytypes.Prim) string bool int;
  inherit (ytypes) Hash FS Git;

# ---------------------------------------------------------------------------- #

  Structs.sourceInfo = struct "sourceInfo" {
    outPath = FS.store_path;
    narHash = Hash.Strings.sha256_sri;
    # Git/Github/Path
    lastModified     = int;
    lastModifiedDate = ytypes.Strings.timestamp;
    # Git/Github
    rev      = option Git.rev;
    shortRev = option string;
    # Git
    revCount   = option int;
    submodules = option bool;
  };


# ---------------------------------------------------------------------------- #

in {
  inherit Structs;
  inherit (Structs) sourceInfo;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
