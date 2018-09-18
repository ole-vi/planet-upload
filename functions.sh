#!/bin/bash

server="https://user:passwd@fosforito.media.mit.edu:2200"

# https://gist.github.com/cdown/1163649
urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
    
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "%s" "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

download_apk() {
    repoUrl="$1"
    repoApkName="$2"
    localApkName="$3"

    latestReleaseUrl="$repoUrl/releases/latest"
    releaseUrl=$(curl -L "$latestReleaseUrl" -w "%{url_effective}" -o /dev/null -s)
    tag=$(echo "$releaseUrl" | sed -r 's/.*\/(.*)/\1/')

    downloadUrl="$repoUrl/releases/download/$tag/$repoApkName"

    curl -s "$downloadUrl" -o "$localApkName" -L
}

downloadable_resource_body() {
    resourceName="$1"
    resourceDesc="$2"
    filename="$3"

    echo '{
        "title": "'"$resourceName"'",
        "description": "'"$resourceDesc"'",
        "tags": [],
        "subject": ["Technology"],
        "level": ["Early Education"],
        "openUrl": null,
        "openWhichFile": "",
        "filename": "'"$filename"'",
        "mediaType": "other",
        "openWith": "Just download",
        "author": "OLE",
        "linkToLicense": "https://www.gnu.org/licenses/agpl-3.0.en.html",
        "createdDate": "1536965901",
        "isDownloadable": "true",
        "publisher": "OLE",
        "year": 2018
    }'
}

website_resource_body() {
    resourceName="$1"
    resourceDesc="$2"

    echo '{
        "title":"'"$resourceName"'",
        "description":"'"$resourceDesc"' website",
        "tags":[],
        "subject":["Technology"],
        "level":["Early Education"],
        "openUrl":null,
        "openWhichFile":"index.html",
        "filename":"",
        "mediaType":"HTML"
    }'
}

upload_apk() {
    resourceName="$1"
    resourceDesc="$2"
    filename="$3"

    mkdir -p /etc/planet
    if [ -f "/etc/planet/data-$resourceName" ]; then
        data=$(cat "/etc/planet/data-$resourceName")
    else
        data=$(curl -s -XPOST -H "Content-type: application/json" -d "$(downloadable_resource_body "$resourceName" "$resourceDesc" "$filename")" $server'/resources')
    fi

    docId=$(echo "$data" | jq -r .id)
    rev=$(echo "$data" | jq -r .rev)

    link=$server'/resources/'$docId'/'"$filename"'?rev='$rev
    newdata=$(curl -s -X PUT "$link" --data-binary "@$filename" -H 'Content-Type:'"$(mimetype -b "$filename")")
    echo "$newdata" > "/etc/planet/data-$resourceName"

    rm -rf "$filename"
}
