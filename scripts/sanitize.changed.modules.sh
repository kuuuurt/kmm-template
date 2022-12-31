#!/bin/bash
CURRENT_BRANCH=$1
BASE_BRANCH=$2

git fetch origin --no-tags

# Figure out changed modules
echo "Finding changed gradle modules..."

MODULES=""
while read line; do

  DIR_LENGTH=0
  if [[ $line = *"android/fastlane"* ]]; then
    DIR_LENGTH=0
  elif [[ $line = *"version.properties"* ]]; then
    DIR_LENGTH=0
  elif [[ $line = *"ios"* ]]; then
    DIR_LENGTH=0
  elif [[ $line = "gradle"* ]]; then
    DIR_LENGTH=0
  elif [[ $line = *"android"* || $line = *"shared"* ]]; then
    DIR_LENGTH=3
  else
    DIR_LENGTH=0
  fi

  if [[ $DIR_LENGTH != 0 && $line = *"test"* && $line != *"testing"* ]]; then
    DIR_LENGTH=$((DIR_LENGTH+1))
  fi

  if [ $DIR_LENGTH != 0 ]; then
    MODULE_NAME=$( echo $line | cut -d/ -f 1-$DIR_LENGTH | tr / : )
    if [[
      # Ignore buildSrc
      ${MODULE_NAME} != "buildSrc"* &&
      # Ignore .md files
      ${MODULE_NAME} != *".md" &&
      # Ignore .properties files
      ${MODULE_NAME} != *".properties" &&
      # Ignore .sh files
      ${MODULE_NAME} != *".sh" &&
      # Ignore .gradle.kts files
      ${MODULE_NAME} != *".kts" &&
      # Ignore if already added
      ${MODULES} != *"${MODULE_NAME}"* &&
      # Ignore ios
      ${MODULE_NAME} != *"ios:"* &&
      # Ignore bills-payment (temporary remove when CI is fixed)
      ${MODULE_NAME} != *"bills"*
    ]]; then
      MODULES="${MODULES} ${MODULE_NAME}"
    fi
  fi
done < <(git diff --name-only $BASE_BRANCH..$CURRENT_BRANCH)
echo "Changed gradle modules are:"
for MODULE in $MODULES
do
  echo "- $MODULE"
done

if [ -z "$MODULE" ]; then
  echo "No changed gradle modules."
  exit 0
fi

# Get gradle commands on changed modules
echo "Preparing gradle tasks to run..."
AVAILABLE_TASKS=$(./gradlew tasks --all)
BUILD_COMMANDS=""
for MODULE in $MODULES
do
  # Static Analysis
  if [[ $AVAILABLE_TASKS =~ $MODULE":detekt" ]]; then
    BUILD_COMMANDS="$BUILD_COMMANDS $MODULE:detekt --auto-correct"
  fi


  # Lint
  if [[ $AVAILABLE_TASKS =~ $MODULE":spotlessApply" ]]; then
    BUILD_COMMANDS="$BUILD_COMMANDS $MODULE:spotlessApply"
  fi

  # Build
  if [[ $AVAILABLE_TASKS =~ $MODULE":compileDebugKotlin" ]]; then
    BUILD_COMMANDS="$BUILD_COMMANDS $MODULE:compileDebugKotlin"
  elif [[ $AVAILABLE_TASKS =~ $MODULE":compileDevDebugKotlin" ]]; then
    BUILD_COMMANDS="$BUILD_COMMANDS $MODULE:compileDevDebugKotlin"
  fi

  # Test
  if [[ $AVAILABLE_TASKS =~ $MODULE":testDevDebugUnitTest" ]]; then
    BUILD_COMMANDS="$BUILD_COMMANDS $MODULE:testDevDebugUnitTest"
  elif [[ $AVAILABLE_TASKS =~ $MODULE":testDebugUnitTest" ]]; then
    BUILD_COMMANDS="$BUILD_COMMANDS $MODULE:testDebugUnitTest"
  fi
done

echo "Running the following commands:"
for BUILD_COMMAND in $BUILD_COMMANDS
do
  echo "- $BUILD_COMMAND"
done

# Run gradle
eval "./gradlew $BUILD_COMMANDS"