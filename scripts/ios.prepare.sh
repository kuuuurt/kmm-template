#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
cd ..

./gradlew shared:firebase:auth:podGenIOS \
  shared:firebase:firestore:podGenIOS \
  shared:firebase:messaging:podGenIOS \
  shared:firebase:remoteconfig:podGenIOS \
  shared:firebase:storage:podGenIOS \
  shared:ios:podGenIOS

cd ios
pod install --repo-update
