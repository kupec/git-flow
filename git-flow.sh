#!/bin/bash
export GIT_MERGE_AUTOEDIT=no 

function premerge {
		BRANCH=$(git rev-parse --abbrev-ref HEAD)
		git checkout develop
		git pull
		git merge --no-ff "$BRANCH"
		git push
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
	vim package.json
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
esac;
