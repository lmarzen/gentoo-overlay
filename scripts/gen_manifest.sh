#!/usr/bin/env bash
# Usage: ./generate_manifest.sh TYPE PATH_OR_URL DEST_FILENAME
# Example: ./generate_manifest.sh DIST https://example.com/file.tar.gz file.tar.gz

set -euo pipefail

TYPE="$1"
INPUT="$2"
#!/usr/bin/env bash
# Usage: ./generate_manifest.sh TYPE PATH_OR_URL [DEST_FILENAME]
# Example: ./generate_manifest.sh DIST https://example.com/file.tar.gz
#          ./generate_manifest.sh EBUILD /path/to/file.ebuild custom_name.ebuild

set -euo pipefail

TYPE="$1"
INPUT="$2"
DEST="${3:-$(basename "$2")}"

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

echo "$TYPE $DEST $SIZE BLAKE2B $BLAKE2B_SUM SHA512 $SHA512_SUM"

