#!/bin/bash

source functions.sh

link="http://treehouses.io"
resourceName=$(basename "$link")
resourceDesc=$(basename "$link")

wget -mkEppq "$link"


mkdir -p /etc/planet
if [ -f "/etc/planet/data-$resourceName" ]; then
    data=$(cat "/etc/planet/data-$resourceName")
else
    data=$(curl -s -XPOST -H "Content-type: application/json" -d "$(website_resource_body "$resourceName" "$resourceDesc" "$filename")" $server'/resources')
fi

echo "$data" > "/etc/planet/data-$resourceName"
docId=$(echo "$data" | jq -r .id)
rev=$(echo "$data" | jq -r .rev)

cd "$(basename "$link")" || exit
while IFS= read -r -d '' d
do
    echo "$d"
    link=$server'/resources/'$docId'/'$(urlencode "$d")'?rev='$rev
    d2=$(curl -s -X PUT "$link" --data-binary "@$d" -H 'Content-Type:'"$(mimetype -b "$d")")
    docId=$(echo "$d2" | jq -r .id)
    rev=$(echo "$d2" | jq -r .rev)
    echo "$d2" > "/etc/planet/data-$resourceName"
done < <(find . -type f -printf '%P\0')
cd ..

rm -rf "$(basename "$link")"