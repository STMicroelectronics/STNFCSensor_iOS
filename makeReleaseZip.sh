#/bin/bash

versionName=$1

git tag $versionName
git push --tags origin 

zip -r ../iosSrc_$versionName.zip . -x '*.git*' '*Carthage/Checkouts*'
