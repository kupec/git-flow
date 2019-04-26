#!/bin/bash
export GIT_MERGE_AUTOEDIT=no

RELEASE_VERSION_FILE=__git_flow__release_version__

function premerge {
    BRANCH=$(getBranch)
    git checkout develop
    git pull
    git merge --no-ff "$BRANCH"
    git push
}

function getBranch {
    git rev-parse --abbrev-ref HEAD
}

function merge {
    premerge
    git checkout "$BRANCH"
    git merge --ff-only develop
}

function finish {
    premerge
    git branch -d "$BRANCH"
}

function start {
    read -p "feature or bug? " -r branch_kind
    read -p "jira key: " -r branch_key
    read -p "description: " -r branch_desc

    if [ -n "$branch_key" ]; then
        key_delimiter=/
    fi;

    git checkout develop
    git pull
    git checkout -b "$branch_kind/$branch_key${key_delimiter}$branch_desc"
}

function release {
    read -p "version: " -r version

    release_branch="release-$version"
    git checkout -b "$release_branch"
    echo "$version" > "$RELEASE_VERSION_FILE"

    echo "Increase version in files and run:"
    echo "  git-flow continue-release"
}

function continue_release {
    read -r version < "$RELEASE_VERSION_FILE"
    rm "$RELEASE_VERSION_FILE"

    release_branch=$(getBranch)

    git add --all
    git commit -m "Increase version to ${version}.0"

    git checkout master
    git pull
    git merge --no-ff "$release_branch"
    git push

    git checkout develop
    git pull
    git merge --no-ff "$release_branch"
    git push
}

case $1 in
    start)
        start;
        ;;

    merge)
        merge;
        ;;

    finish)
        finish;
        ;;

    release)
        release;
        ;;

    continue-release)
        continue_release;
        ;;
esac;
