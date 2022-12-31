#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
cd ../../..

git checkout develop
(git show-branch release/staging/android/ph &>/dev/null) && (git checkout release/staging/android/ph) || (git checkout -b release/staging/android/ph && git push --set-upstream origin release/staging/android/ph) 
git pull origin develop
git push

VERSION=$(android/version.sh staging ph)

gh pr create \
    -a @me \
    -B staging/android/ph \
    -H release/staging/android/ph \
    -t $VERSION \
    -l release \
    -f

gh pr merge --auto -m

git checkout develop