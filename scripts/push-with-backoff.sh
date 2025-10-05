#!/bin/bash

set -e

# GitHub Actions doesn't easily let use make jobs run sequentially, therefore
# could have pushes be rejected by the remote because multiple push attempts
# occurred at the same time.
# A naive (but valid) solution is to keep trying until it is accepted. We add a
# random sleep time to try to reduce conflicts.

BRANCH=${1:-main}  # default to 'main'
MAX_RETRIES=5

git pull --rebase origin "$BRANCH" || true
for i in $(seq 1 $MAX_RETRIES); do
  if git push origin "$BRANCH"; then
    echo "Push succeeded"
    exit 0
  else
    echo "Push failed, retrying..."
    git pull --rebase origin "$BRANCH"
    sleep $((RANDOM % 10 + 1))  # random backoff
  fi
done

echo "ERROR: Push to '$BRANCH' failed after $MAX_RETRIES attempts."
exit 1
