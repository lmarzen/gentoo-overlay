#!/bin/bash

set -e

OVERLAY_REPO="gentoo-overlay"
DISTFILES_BRANCH="distfiles"

echo "Regenerating manifest..."
MAN="$ECN/$EPN/Manifest"
CATEGORY="$ECN"
PN="$EPN"
rm -f "$MAN"

for ebuild in "$CATEGORY/$PN"/*.ebuild; do
    echo "Updating $MAN for $ebuild"
    PV=$(echo "$ebuild" | grep -oP '\d+(\.\d+){0,2}')
    PVR=$(echo "$ebuild" | grep -oP '\d+(\.\d+){0,2}(-[a-z0-9]+)?')
    P=$PN-$PV
    PF=$PN-$PVR

    echo $CATEGORY $PN $PV $PVR $P $PF
    echo $ebuild

    if [ -d "$CATEGORY/$PN/files/" ]; then
        for file in "$CATEGORY/$PN/files/"*; do
            echo "  $file"
            scripts/gen_manifest.sh "$MAN" AUX "$file"
        done
    fi
    if [[ $PV != 9999 ]]; then
        while IFS="|" read -r SRC_URI DEST; do
            echo "SRC_URI='$SRC_URI'"
            echo "DEST='$DEST'"
            echo "evaluating SRC_URI and DEST..."
            eval "SRC_URI=$SRC_URI"
            eval "DEST=$DEST"
            echo "SRC_URI='$SRC_URI'"
            echo "DEST='$DEST'"
            if [[ -z "$DEST" ]]; then
                scripts/gen_manifest.sh "$MAN" DIST "${SRC_URI}"
            else
                scripts/gen_manifest.sh "$MAN" DIST "${SRC_URI}" "${DEST}"
            fi
        done < <(python3 scripts/parse-src-uri.py "$ebuild")
    fi
    scripts/gen_manifest.sh "$MAN" EBUILD "$ebuild"
    scripts/gen_manifest.sh "$MAN" MISC "$CATEGORY/$PN/metadata.xml"
done

echo "Checking if manifest changed..."
MAN_UPDATED=0
if git ls-files --error-unmatch "$MAN" > /dev/null 2>&1; then
    if git diff --quiet -- "$MAN"; then
        echo "$MAN unmodified"
        MAN_UPDATED=false
    else
        echo "$MAN modified"
        MAN_UPDATED=true
    fi
else
    echo "$MAN created"
    MAN_UPDATED=true
fi
if [[ $MAN_UPDATED == true ]]; then
    git add "$MAN"
    git commit -m "Updated manifest for $ECN/$EPN"
fi

if [[ -n "$GITHUB_ENV" ]]; then
    if [[ $MANIFEST_UPDATED != true ]]; then
        echo "MANIFEST_UPDATED=$MAN_UPDATED"
        echo "MANIFEST_UPDATED=$MAN_UPDATED" >> "$GITHUB_ENV"
    fi
fi
