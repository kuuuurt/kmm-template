#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
cd ../../..

git checkout develop
(git show-branch release/dev/android/ph &>/dev/null) && (git checkout release/dev/android/ph) || (git checkout -b release/dev/android/ph && git push --set-upstream origin release/dev/android/ph)
git pull origin develop
git push

VERSION=$( android/version.sh dev ph)

gh pr create \
    -a @me \
    -B dev/android/ph \
    -H release/dev/android/ph \
    -t $VERSION \
    -l release \
    -f

gh pr merge --auto -m

git checkout develop