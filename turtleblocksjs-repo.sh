#!/bin/bash

source functions.sh

repo="https://github.com/walterbender/turtleblocksjs"
resourceName=$(basename "$repo")
resourceDesc=$(basename "$repo")

git clone $repo

data=$(curl -XPOST -H "Content-type: application/json" -d '{"title":"'"$resourceName"'","description":"'"$resourceDesc"' website","tags":[],"subject":["Technology"],"level":["Early Education"],"openUrl":null,"openWhichFile":"index.html","filename":"","mediaType":"HTML"}' $server'/resources')
docId=$(echo "$data" | jq -r .id)
rev=$(echo "$data" | jq -r .rev)

cd "$(basename "$repo")" || exit
while IFS= read -r -d '' d
do
    echo "$d"
    link=$server'/resources/'$docId'/'$(urlencode "$d")'?rev='$rev
    d2=$(curl -s -X PUT "$link" --data-binary "@$d" -H 'Content-Type:'"$(mimetype -b "$d")")
    rev=$(echo "$d2" | jq -r .rev)
done < <(find . -type f -printf '%P\0')
cd ..

rm -rf "$(basename $repo)"