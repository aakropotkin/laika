# ============================================================================ #
#
# Utilities to generate `__functionMeta' for fetchers comprised of
# many sub-fetchers.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

 # Generate `innerName' from sub-fetchers' `__functionMeta.(name|from)'.
  mergeInnerName = fetchers: let
    fromToString = f: ns: let
      getName  = fetcher: fetcher.__functionMeta.name or "?";
      namesToString = ns:
        if ( builtins.length ns ) == 1
        then getName ( builtins.head ns )
        else "<${builtins.concatStringsSep "|" ( map getName ns )}>";
      loc = if f == "_%NONE%_" then "" else f + ".";
    in loc + ( namesToString ns );
    fromStrings = let
      getFrom = fetcher: fetcher.__functionMeta.from or "_%NONE%_";
      froms   = builtins.groupBy getFrom ( builtins.attrValues fetchers );
    in builtins.attrValues ( builtins.mapAttrs fromToString froms );
  in builtins.concatStringsSep "|" fromStrings;


# ---------------------------------------------------------------------------- #

  # Assumes `false' if unset.
  mergeBoolProperty = fetchers: field: let
    has = f: f.__functionMeta.properties.${field} or false;
  in builtins.all has ( builtins.attrValues fetchers );

  mergeProperties = fetchers: let
    proc = acc: field: acc // ( mergeBoolProperty fetchers field );
  in builtins.foldl' proc {} ["builtin" "pure" "typecheck"];


# ---------------------------------------------------------------------------- #

in {
  inherit
    mergeInnerName
    mergeBoolProperty
    mergeProperties
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
