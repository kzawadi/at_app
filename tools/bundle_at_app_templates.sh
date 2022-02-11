#!/bin/bash
TOOL_PATH="${BASH_SOURCE%/*}"
BASE_PATH="$TOOL_PATH/../templates"
BRICK_PATH="$BASE_PATH/lib"
OUTPUT_PATH="$TOOL_PATH/../at_app"

rm "$OUTPUT_PATH/lib/src/bundles/bundles.dart"
touch "$OUTPUT_PATH/lib/src/bundles/bundles.dart"
for x in "$BRICK_PATH"/*;
  do
  xbase=$(basename "$x")
  echo "export '$xbase/$xbase.dart';" >> "$OUTPUT_PATH/lib/src/bundles/bundles.dart"
  rm "$OUTPUT_PATH/lib/src/bundles/$xbase/$xbase.dart"
  touch "$OUTPUT_PATH/lib/src/bundles/$xbase/$xbase.dart"
  for y in "$x"/*;
  do
    ybase=$(basename "$y")
    echo "export '$ybase/$ybase.dart';" >> "$OUTPUT_PATH/lib/src/bundles/$(basename "$x")/$(basename "$x").dart"
    dart run "$TOOL_PATH/template_bundler/bin/main.dart" bundle -o "$OUTPUT_PATH/lib/src/bundles/$xbase/$ybase" "$y";
  done
done
