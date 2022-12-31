#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
cd ../../..

git checkout develop
(git show-branch release/dev/ios/ph &>/dev/null) && (git checkout release/dev/ios/ph) || (git checkout -b release/dev/ios/ph && git push --set-upstream origin release/dev/ios/ph)
git pull origin develop
git push

VERSION=$( ios/version.sh dev)

gh pr create \
    -a @me \
    -B dev/ios/ph \
    -H release/dev/ios/ph \
    -t $VERSION \
    -l release \
    -f

gh pr merge --auto -m

git checkout develop
