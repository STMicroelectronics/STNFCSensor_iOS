#/bin/bash
releaseName=$1
projectDir=$(pwd)
cd ..
cp -r $projectDir $releaseName
cd $releaseName
rm -rf .git
rm -rf  Carthage
cd ..
zip -r $releaseName.zip $releaseName
rm -rf $releaseName
