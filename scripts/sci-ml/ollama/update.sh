#!/bin/bash

set -e

ECN="sci-ml"
EPN="ollama"
OVERLAY_REPO="gentoo-overlay"
DISTFILES_BRANCH="distfiles"

echo "Fetching latest Ollama release..."
LATEST_TAG=$(curl -s https://api.github.com/repos/ollama/ollama/releases/latest | jq -r .tag_name)
LATEST_VERSION=$(echo "$LATEST_TAG" | sed 's/^v//')
echo "Latest tag: $LATEST_TAG"
echo "Latest version: $LATEST_VERSION"

EBUILD_PATH="$ECN/$EPN/$EPN-$LATEST_VERSION.ebuild"
if [ -f "$EBUILD_PATH" ]; then
    NEW_RELEASE=false
    echo "Ebuild for latest release already exists. Skipping vendor tarball and ebuild creation."
else
    NEW_RELEASE=true
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
    git pull --rebase origin "$DISTFILES_BRANCH" || true
    git push origin "$DISTFILES_BRANCH"

    echo "Creating ebuild..."
    git switch main
    cp "$ECN/$EPN/${EPN}-9999.ebuild" "$ECN/$EPN/${EPN}-${LATEST_VERSION}.ebuild"
    git add "$ECN/$EPN/${EPN}-${LATEST_VERSION}.ebuild"

    echo "Committing new ebuild..."
    git commit -m "Add ebuild for new $ECN/$EPN releases tag $LATEST_TAG"

    scripts/regen-manifest.sh
fi
