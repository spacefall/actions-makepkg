#!/usr/bin/env bash
set -e

directory=$(readlink "/github/workspace/$1" -f)
reponame=$2

cd $directory

echo "==> Setting up a package database"
repo-add "$directory/$reponame.db.tar.gz" "$directory"/*.pkg.*

echo "==> Replacing symlinks"
for file in *.db *.files; do
  cp --remove-destination "$(readlink "$file")" "$file"
done
