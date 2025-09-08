#!/usr/bin/env bash
# Usage: ./generate_manifest.sh MANIFEST_FILE TYPE PATH_OR_URL [DEST_FILENAME]
# Example: ./generate_manifest.sh manifest DIST https://example.com/file.tar.gz
#          ./generate_manifest.sh manifest EBUILD /path/to/file.ebuild custom_name.ebuild

set -euo pipefail

MANIFEST="$1"
TYPE="$2"
INPUT="$3"
DEST="${4:-$(basename "$3")}"

# Determine if INPUT is a URL (starts with http:// or https://)
if [[ "$INPUT" =~ ^https?:// ]]; then
    TMPFILE="/tmp/$DEST"
    curl -L -o "$TMPFILE" "$INPUT"
    FILE="$TMPFILE"
else
    FILE="$INPUT"
fi

if [[ ! -f "$FILE" ]]; then
    echo "Error: file '$FILE' not found"
    exit 1
fi

SIZE=$(stat -c%s "$FILE")
BLAKE2B_SUM=$(b2sum "$FILE" | awk '{print $1}')
SHA512_SUM=$(sha512sum "$FILE" | awk '{print $1}')

LINE="$TYPE $DEST $SIZE BLAKE2B $BLAKE2B_SUM SHA512 $SHA512_SUM"

touch "$MANIFEST"
if ! grep -Fxq "$LINE" "$MANIFEST"; then
    echo "Writing '$LINE' to $MANIFEST."
    # Remove any old line containing DEST
    sed -i "/ $DEST /d" "$MANIFEST"
    echo "$LINE" >> "$MANIFEST"
    sort -o "$MANIFEST" "$MANIFEST"
else
    echo "Manifest is already up-to-date."
fi

