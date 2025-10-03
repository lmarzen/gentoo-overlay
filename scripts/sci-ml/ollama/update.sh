#!/bin/bash

set -e

# Configuration
ECN="sci-ml"
EPN="ollama"
OVERLAY_REPO="gentoo-overlay"
DISTFILES_BRANCH="distfiles"

# Step 1: Get latest Ollama release tag and version
echo "Fetching latest Ollama release..."
LATEST_TAG=$(curl -s https://api.github.com/repos/ollama/ollama/releases/latest | jq -r .tag_name)
LATEST_VERSION=$(echo "$LATEST_TAG" | sed 's/^v//')
echo "Latest tag: $LATEST_TAG"
echo "Latest version: $LATEST_VERSION"

EBUILD_PATH="$ECN/$EPN/$EPN-$LATEST_VERSION.ebuild"
if [ -f "$EBUILD_PATH" ]; then
    NEW_RELEASE=0
    echo "Ebuild for latest release already exists. Skipping vendor tarball and ebuild creation."
else
    NEW_RELEASE=1
    echo "New release detected. Proceeding with vendor tarball and ebuild creation."

    echo "Cloning ollama repository..."
    cd ..
    OLLAMA_REPO="$EPN-$LATEST_VERSION"
    git clone --depth 1 --branch "$LATEST_TAG" https://github.com/ollama/ollama.git "$OLLAMA_REPO"

    echo "Setting up Go and vendoring dependencies..."
    cd "$OLLAMA_REPO"
    go mod tidy
    go mod vendor
    cd ..

    echo "Creating vendor tarball..."
    tar -caf "${EPN}-${LATEST_VERSION}-vendor.tar.xz" "$OLLAMA_REPO/vendor"

    echo "Switching to distfiles branch..."
    cd $OVERLAY_REPO
    git checkout "$DISTFILES_BRANCH" || git switch --orphan "$DISTFILES_BRANCH"

    echo "Moving tarball to distfiles..."
    mkdir -p "$ECN/$EPN"
    mv "../${EPN}-${LATEST_VERSION}-vendor.tar.xz" "$ECN/$EPN/"

    echo "Committing and pushing distfiles changes..."
    git add "$ECN/$EPN/${EPN}-${LATEST_VERSION}-vendor.tar.xz"
    git commit -m "Add vendor distfiles for new $ECN/$EPN releases tag $LATEST_TAG" || true
    git push origin "$DISTFILES_BRANCH" || true

    echo "Creating ebuild..."
    cp "$ECN/$EPN/${EPN}-9999.ebuild" "$ECN/$EPN/${EPN}-${LATEST_VERSION}.ebuild"
    git add "$ECN/$EPN/${EPN}-${LATEST_VERSION}.ebuild"
fi

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

    for file in "$CATEGORY/$PN/files/"*; do
        echo "  $file"
        scripts/gen_manifest.sh "$MAN" AUX "$file"
    done
    if [[ $PV != 9999 ]]; then
        scripts/gen_manifest.sh "$MAN" DIST "https://github.com/ollama/${PN}/archive/refs/tags/v${PV}.tar.gz" "${P}.gh.tar.gz"
        scripts/gen_manifest.sh "$MAN" DIST "https://github.com/lmarzen/gentoo-overlay/raw/refs/heads/distfiles/${CATEGORY}/${PN}/${P}-vendor.tar.xz"
    fi
    scripts/gen_manifest.sh "$MAN" EBUILD "$ebuild"
    scripts/gen_manifest.sh "$MAN" MISC "$CATEGORY/$PN/metadata.xml"
done

echo "Checking if manifest changed..."
MAN_UPDATED=0
if git ls-files --error-unmatch "$MAN" > /dev/null 2>&1; then
    if git diff --quiet -- "$MAN"; then
        echo "$MAN unmodified"
        MAN_UPDATED=0
    else
        echo "$MAN modified"
        MAN_UPDATED=1
    fi
else
    echo "$MAN created"
    MAN_UPDATED=1
fi
if $MAN_UPDATED; then
    git add "$MAN"
    if $NEW_RELEASE; then
        git commit -m "Add ebuild for new $ECN/$EPN releases tag $LATEST_TAG" || true
    else
        git commit -m "Updated manifest for $ECN/$EPN" || true
    fi
    git pull --rebase || true
    git push || true
fi

if [ -n "$GITHUB_OUTPUT" ]; then
    echo "changed=$MAN_UPDATED" >> "$GITHUB_OUTPUT"
fi
