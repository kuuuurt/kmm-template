#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
cd ../../..

git checkout develop
(git show-branch release/staging/ios/ph &>/dev/null) && (git checkout release/staging/ios/ph) || (git checkout -b release/staging/ios/ph && git push --set-upstream origin release/staging/ios/ph) 
git pull origin develop
git push
