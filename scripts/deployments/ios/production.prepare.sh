#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
cd ../../..

git checkout staging/ios/ph
(git show-branch release/production/ios/ph &>/dev/null) && (git checkout release/production/ios/ph) || (git checkout -b release/production/ios/ph && git push --set-upstream origin release/production/ios/ph)
git pull origin staging/ios/ph
