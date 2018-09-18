#!/bin/bash

source functions.sh

resourceName="remote apk"
resourceDesc="treehouses/remote app"

repoUrl="https://github.com/treehouses/remote"
fName="app-debug.apk"
planetfName="remote.apk"

download_apk "$repoUrl" "$fName" "$planetfName"
upload_apk "$resourceName" "$resourceDesc" "$planetfName"