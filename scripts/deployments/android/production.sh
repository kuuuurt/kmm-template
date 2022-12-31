#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
cd ../../..

git checkout staging/android/ph
(git show-branch release/production/android/ph &>/dev/null) && (git checkout release/production/android/ph) || (git checkout -b release/production/android/ph && git push --set-upstream origin release/production/android/ph)
git pull origin staging/android/ph

VERSION=$( android/version.sh production ph)
DATE=$(date +%F)
RELEASE=$(awk 1 ORS='\\n' android/philippines/RELEASE.md)

# Write release notes to changelog
awk -v VERSION=$VERSION \
    -v DATE=$DATE \
    -v RELEASE="$RELEASE" \
    'NR==7{printf "- ## " VERSION " - " DATE "\n" RELEASE "\n"} 1' \
    android/philippines/CHANGELOG.md > android/philippines/CHANGELOG.md.bak

# Cleanup temp files
cat android/philippines/CHANGELOG.md.bak > android/philippines/CHANGELOG.md
rm -rf android/philippines/CHANGELOG.md.bak

git commit -am "Prepares $VERSION"
git push

gh pr create \
    -a @me \
    -B production/android/ph \
    -H release/production/android/ph \
    -t $VERSION \
    -l release \
    -f

gh pr merge --auto -m

git checkout develop