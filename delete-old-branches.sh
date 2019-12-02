#!/bin/sh
# Somewhat effectively clean up own branches

filter="osmith"

if ! [ -d ".git" ]; then
	echo "ERROR: run this script in the top dir of a cloned git repository."
	exit 1
fi

branches="$(git branch | grep "$filter")"
count_old="$(git branch | grep "$filter" | wc -l)"
i=0
for branch in $branches; do
	i=$((i+1))

	echo "--- ($i/$count_old) ---"
	if [ -n "$(git branch --merged master "$branch")" ]; then
		echo "Branch '$branch' is merged into master!"
	else
		git log -n1 "$branch"
	fi

	read -p "Delete branch '$branch'? [y/N] " yn
	if [ "$yn" != "y" ]; then
		echo "Skipping..."
		continue
	fi

	echo "Deleting..."
	if git show-branch remotes/origin/"$branch" >/dev/null 2>&1; then
		git push -d origin "$branch"
	else
		echo "Branch does not exist remotely."
	fi
	git branch -D "$branch"
done

count_new="$(git branch | grep "$filter" | wc -l)"
echo "---"
echo "Branch count: $count_old -> $count_new"
