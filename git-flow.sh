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
    git checkout -b "$release_branch" develop
    echo "$version" > "$RELEASE_VERSION_FILE"

    echo "Increase version in files and run:"
    echo "  git-flow continue-release"
    echo "or"
    echo "  git-flow continue-demo-release"
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

function continue_demo_release {
    read -r version < "$RELEASE_VERSION_FILE"
    rm "$RELEASE_VERSION_FILE"

    release_branch=$(getBranch)

    git add --all
    git commit -m "Increase version to ${version}.0"

    git checkout develop
    git pull
    git merge --no-ff "$release_branch"
    git push
}

function hotfix {
    read -p "version: " -r version

    hotfix_branch="hotfix-$version"
    git checkout -b "$hotfix_branch" master

    echo "Do hotfix and run:"
    echo "  git-flow finish-hotfix"
}

function finish_hotfix {
    hotfix_branch=$(getBranch)

    git checkout master
    git pull
    git merge --no-ff "$hotfix_branch"
    git push

    git checkout develop
    git pull
    git merge --no-ff "$hotfix_branch"
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

    continue-demo-release)
        continue_demo_release;
        ;;

    continue-release)
        continue_release;
        ;;

    hotfix)
        hotfix;
        ;;

    finish-hotfix)
        finish_hotfix;
        ;;
esac;
