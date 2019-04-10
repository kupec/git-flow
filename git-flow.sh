#!/bin/bash

function premerge {
		BRANCH=$(git rev-parse --abbrev-ref HEAD)
		git checkout develop
		git pull
		GIT_MERGE_AUTOEDIT=no git merge --no-ff "$BRANCH"
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
	git checkout develop
	git pull
	git checkout -b "$branch_kind/$branch_key/$branch_desc"
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
esac;
