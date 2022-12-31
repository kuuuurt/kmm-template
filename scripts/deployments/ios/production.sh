#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
cd ../../..

git checkout staging/ios/ph
(git show-branch release/production/ios/ph &>/dev/null) && (git checkout release/production/ios/ph) || (git checkout -b release/production/ios/ph && git push --set-upstream origin release/production/ios/ph)
git pull origin staging/ios/ph

VERSION=$( ios/version.sh production)
DATE=$(date +%F)
RELEASE=$(awk 1 ORS='\\n' ios/RELEASE.md)

# Write release notes to changelog
awk -v VERSION=$VERSION \
    -v DATE=$DATE \
    -v RELEASE="$RELEASE" \
    'NR==7{printf "- ## " VERSION " - " DATE "\n" RELEASE "\n"} 1' \
    ios/CHANGELOG.md > ios/CHANGELOG.md.bak

# Cleanup temp files
cat ios/CHANGELOG.md.bak > ios/CHANGELOG.md
rm -rf ios/CHANGELOG.md.bak

git commit -am "Prepares $VERSION"
git push

gh pr create \
    -a @me \
    -B production/ios/ph \
    -H release/production/ios/ph \
    -t $VERSION \
    -l release \
    -f

gh pr merge --auto -m

git checkout develop
