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

case $1 in
	merge)
		merge;
		;;

	finish)
		finish;
		;;
esac;
