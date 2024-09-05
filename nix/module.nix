self:
{ lib
, ...
}:
{
  options.palette =
  let
    inherit (import ./lib/hex2rgb.nix { inherit lib; }) hexToRgb;
    inherit (import ./lib/hex2rgba.nix { inherit lib; }) hexToRgba;
    inherit (builtins)
      elemAt listToAttrs match filter stringLength substring isPath mapAttrs;

    testFunction = namePath: 
    let
      formedPath = if (isPath namePath) then namePath else (../. + "/src/${namePath}.yml");
      rawData = builtins.readFile formedPath;

      lines = lib.strings.splitString "\n" rawData;
      linesNoComments = map (line: elemAt (match "(^[^#]*)($|#.*$)" line) 0) lines;
      linesNoEmpty = filter (line: line != null && line != "") linesNoComments;
      linesNoSpacesAtEnd = map (line: elemAt (match "(.*[^ ])[ ]*$" line) 0) linesNoEmpty;

      nameValuePair = name: value: { inherit name value; };
      nameValueObject = line: let objectLocal = (match "([^ :]+): *(.*)" line); in
        nameValuePair (elemAt objectLocal 0) (elemAt objectLocal 1);

      paletteDirty = listToAttrs (map nameValueObject linesNoSpacesAtEnd);

      filterBaseColors = key: match "[bB][aA][sS][eE][0-9A-Fa-f]{2}" key != null;

      cutQuotes = c: substring 1 (stringLength c - 2) c;

      paletteNoQuotes = mapAttrs (name: value: cutQuotes value) paletteDirty;
  
      colorOptions = color: {
        hex = color;
        hexT = "#${color}";
        rgb = hexToRgb (color);
        rgba = arg: hexToRgba (color) arg;
      };

      palette = mapAttrs (key: value:
        if filterBaseColors key then
          colorOptions value
        else
          value
        ) paletteNoQuotes;
    in palette;

  in lib.options.mkOption {
    description = "Palette for base16x2. (path or palette name are required)";
    type = with lib.types; coercedTo (oneOf [ path str ]) testFunction (attrsOf anything);
  };
}
