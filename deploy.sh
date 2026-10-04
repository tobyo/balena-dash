#!/bin/bash
# Deploy to balena with yearly-calendar at the latest main.
#
# balena push uploads the working tree, so whatever is checked out in
# yearly-calendar/ is what ships. This brings it up to origin/main first,
# refuses to ship anything that is not on GitHub, and records the commit
# that was deployed. Extra arguments are passed through to balena push.
set -euo pipefail

FLEET="${BALENA_FLEET:-g_toby_oliver/casablanca-dash}"
SUB=yearly-calendar
BRANCH=main

die() { echo "deploy: $*" >&2; exit 1; }

cd "$(dirname "$0")"

# Check everything before changing anything.
balena whoami >/dev/null 2>&1 || die "balena CLI is not logged in; run 'balena login'"

[ "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH" ] || die "this repo is not on $BRANCH"
git diff --quiet --ignore-submodules=dirty -- . ":!$SUB" &&
  git diff --cached --quiet --ignore-submodules=dirty -- . ":!$SUB" ||
  die "this repo has uncommitted changes; commit or stash them first"

[ "$(git -C "$SUB" rev-parse --abbrev-ref HEAD)" = "$BRANCH" ] || die "$SUB is not on $BRANCH"
[ -z "$(git -C "$SUB" status --porcelain)" ] || die "$SUB has uncommitted or untracked changes"

git -C "$SUB" fetch --quiet origin
[ -z "$(git -C "$SUB" rev-list "origin/$BRANCH..HEAD")" ] ||
  die "$SUB has commits that are not on GitHub; push them first"
git -C "$SUB" merge --quiet --ff-only "origin/$BRANCH" ||
  die "$SUB could not be fast-forwarded to origin/$BRANCH"

sha=$(git -C "$SUB" rev-parse --short HEAD)
if git diff --quiet -- "$SUB"; then
  echo "deploy: $SUB already recorded at $sha"
else
  git add "$SUB"
  git commit --quiet -m "Update $SUB to $sha" -- "$SUB"
  echo "deploy: recorded $SUB at $sha"
fi

git push --quiet origin "$BRANCH"
echo "deploy: pushing to $FLEET"
balena push "$FLEET" "$@"
