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
    if [[ $ebuild == *9999* ]]; then
        PV=9999
        PVR=9999
    else
        PV=$(echo "$ebuild" | grep -oP '\d+\.\d+\.\d+')
        PVR=$(echo "$ebuild" | grep -oP '\d+\.\d+\.\d+(-[a-z0-9]+)?')
    fi
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
        # assumes single source
        eval "SRC_URI=$(grep '^SRC_URI=' "$ebuild" | sed -E 's/^SRC_URI="([^" ]+).*/\1/')"
        eval "DEST=$(grep '^SRC_URI=' "$ebuild" | sed -n 's/.*\-> \(.*\)"$/\1/p')"
        if [[ -z "$DEST" ]]; then
            scripts/gen_manifest.sh "$MAN" DIST "${SRC_URI}"
        else
            scripts/gen_manifest.sh "$MAN" DIST "${SRC_URI}" "${DEST}"
        fi
        # scripts/gen_manifest.sh "$MAN" DIST "https://github.com/lmarzen/gentoo-overlay/raw/refs/heads/distfiles/${CATEGORY}/${PN}/${P}-vendor.tar.xz"
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
    if [ $MANIFEST_UPDATED == true ]; then
        echo "MANIFEST_UPDATED=$MAN_UPDATED" >> "$GITHUB_ENV"
    fi
fi
