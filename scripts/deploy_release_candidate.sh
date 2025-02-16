#!/bin/bash
set -ex

MAJOR_VERSION=0
MINOR_VERSION=14

latestRcTag=$(git tag --sort=-version:refname | grep "^${MAJOR_VERSION}.${MINOR_VERSION}.\d\+" | head -n 1 | grep --only-matching "^${MAJOR_VERSION}.${MINOR_VERSION}.\d\+" || true)

if [ "$latestRcTag" == "" ]; then
    nextVersion=$MAJOR_VERSION.$MINOR_VERSION.0
else
    # TODO: remove the comment once we are ready to remove the staging deployment
    # nextVersion=$(echo $latestRcTag | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')
    nextVersion=$latestRcTag
fi

export DATREE_BUILD_VERSION=$nextVersion-rc
echo $DATREE_BUILD_VERSION

git tag $DATREE_BUILD_VERSION -a -m "Generated tag from TravisCI for build $TRAVIS_BUILD_NUMBER"
git push --tags

bash ./scripts/sign_application.sh
curl -sL https://git.io/goreleaser | VERSION=v$GORELEASER_VERSION bash

bash ./scripts/brew_push_formula.sh staging $DATREE_BUILD_VERSION
