#!/bin/bash

source functions.sh

resourceName="myPlanet app"
resourceDesc="myPlanet app"

repoUrl="https://github.com/open-learning-exchange/myplanet"
fName="app-debug.apk"
planetfName="myplanet.apk"

download_apk "$repoUrl" "$fName" "$planetfName"
upload_apk "$resourceName" "$resourceDesc" "$planetfName"