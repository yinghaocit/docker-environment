#!/bin/bash

set -e

TERM=xterm-color

BASE_BRANCH=$1
FEATURED_BRANCH=$2

if [ -z "$BASE_BRANCH" ]
then
    echo "BASE_BRANCH must be set"
    exit 1
fi

if [ -z "$FEATURED_BRANCH" ]
then
    echo "FEATURED_BRANCH must be set"
    exit 1
fi

CURRENT_REF=$(git rev-parse HEAD)

commit=$(git rev-parse origin/${BASE_BRANCH})

merge_base="$(git merge-base "$commit" "origin/${FEATURED_BRANCH}")"

if [ "$merge_base" != "$(git rev-parse --verify "$commit")" ]
then
  echo -e "\e[1;33m origin/${FEATURED_BRANCH} is not based on origin/${BASE_BRANCH} \e[0m"

  git branch ${FEATURED_BRANCH} origin/${FEATURED_BRANCH} || true
  git checkout -f ${FEATURED_BRANCH}
  git reset --hard origin/${FEATURED_BRANCH}

  if git rebase origin/${BASE_BRANCH}
  then
    echo -e "\e[1;33m An automatically rebase attempt for origin/${FEATURED_BRANCH} to origin/${BASE_BRANCH} has succeeded, skip rest build stages, a new build should be start shortly. \e[0m"

    git push -f origin ${FEATURED_BRANCH}:${FEATURED_BRANCH}

    git checkout -f ${CURRENT_REF}
    exit 1
  else
    echo -e "\e[1;31m An automatically rebase attempt for origin/${FEATURED_BRANCH} to origin/${BASE_BRANCH} has failed \e[0m"

    git status
    git diff
    git rebase --abort

    git checkout -f ${CURRENT_REF}
    exit 1
  fi
elif [[ -n "$(git rev-list --merges origin/${BASE_BRANCH}..origin/${FEATURED_BRANCH})" ]]
then
  echo -e "\e[1;33m There should not be any merge commit between origin/${BASE_BRANCH} and origin/${FEATURED_BRANCH} \e[0m"
  exit 1
fi

git checkout -f ${CURRENT_REF}
