#!/usr/bin/env bash

# This file contains parts from the scripts taken from the Open GApps Project by mfonville.
#
# The Open GApps scripts are free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

echo ".______...__...__..__...._.._______..__...__..___..._______."
echo "|......\.|..|.|..||..\..|.||..._...||..\_/..||...|.|...____|"
echo "|..__...||..|_|..||...\_|.||..| |..||.......||...|.|..|....."
echo "|.|. \..||.......||.......||..|_|..||.......||...|.|..|....."
echo "|.|__/..||_....._||.._....||.......||.......||...|.|..|....."
echo "|.......|..|...|..|.|.\...||..._...||.||_||.||...|.|..|____."
echo "|______/...|___|..|_|..\__||__|.|__||_|...|_||___|.|_______|"
echo "._______.._______.._______.._______.._______................"
echo "|.......||..._...||...._..||...._..||.......|..............."
echo "|....___||..| |..||...| |.||...| |.||.._____|..............."
echo "|...|.__.|..|_|..||...|_|.||...|_|.||.|_____................"
echo "|...||..||.......||....___||....___||_____..|..............."
echo "|...|_|.||..._...||...|....|...|....._____|.|..............."
echo "|_______||__|.|__||___|....|___|....|_______|..............."

# Define paths & variables
APPDIRS="facelock/arm/app/FaceLock
         googlevrcore/arm/app/GoogleVrCore
         googlevrcore/arm64/app/GoogleVrCore
         prebuiltgmscore/arm/priv-app/PrebuiltGmsCore
         prebuiltgmscore/arm64/priv-app/PrebuiltGmsCore
         setupwizard/phone/priv-app/SetupWizard
         setupwizard/tablet/priv-app/SetupWizard
         system/app/GoogleCalendarSyncAdapter
         system/app/GoogleContactsSyncAdapter
         system/app/GoogleTTS
         system/priv-app/ConfigUpdater
         system/priv-app/GoogleBackupTransport
         system/priv-app/GoogleFeedback
         system/priv-app/GoogleLoginService
         system/priv-app/GoogleOneTimeInitializer
         system/priv-app/GooglePartnerSetup
         system/priv-app/GoogleServicesFramework
         system/priv-app/HotwordEnrollment
         system/priv-app/Phonesky
         velvet/arm/priv-app/Velvet
         velvet/arm64/priv-app/Velvet"
TARGETDIR=$(pwd)
GAPPSDIR="$TARGETDIR"/files
TOOLSDIR="$TARGETDIR"/tools
STAGINGDIR="$TARGETDIR"/staging
FINALDIR="$TARGETDIR"/out
ZIPTITLE=Dynamic_GApps
ZIPVERSION=7.x.x
ZIPDATE=$(date +"%Y%m%d")
ZIPNAME="$ZIPTITLE"-"$ZIPVERSION"-"$ZIPDATE".zip
JAVAHEAP=3072m
SIGNAPK="$TOOLSDIR"/signapk.jar
MINSIGNAPK="$TOOLSDIR"/minsignapk.jar
TESTKEYPEM="$TOOLSDIR"/testkey.x509.pem 
TESTKEYPK8="$TOOLSDIR"/testkey.pk8

# Decompression function for apks
dcapk() {
  TARGETDIR=$(pwd)
  TARGETAPK="$TARGETDIR"/$(basename "$TARGETDIR").apk
  unzip -qo "$TARGETAPK" -d "$TARGETDIR" "lib/*"
  zip -qd "$TARGETAPK" "lib/*"
  cd "$TARGETDIR"
  zip -qrDZ store -b "$TARGETDIR" "$TARGETAPK" "lib/"
  rm -rf "${TARGETDIR:?}"/lib/
  mv -f "$TARGETAPK" "$TARGETAPK".orig
  zipalign -fp 4 "$TARGETAPK".orig "$TARGETAPK"
  rm -f "$TARGETAPK".orig
}

# Define beginning time
BEGIN=$(date +"%s")

# Start making GApps zip
export PATH="$TOOLSDIR":$PATH
cp -rf "$GAPPSDIR"/* "$STAGINGDIR"

for dirs in $APPDIRS; do
  cd "$STAGINGDIR/${dirs}";
  dcapk 1> /dev/null 2>&1;
done

cd "$STAGINGDIR"
zip -qr9 "$ZIPNAME" ./* -x "placeholder"
java -Xmx"$JAVAHEAP" -jar "$SIGNAPK" -w "$TESTKEYPEM" "$TESTKEYPK8" "$ZIPNAME" "$ZIPNAME".signed
rm -f "$ZIPNAME"
zipadjust "$ZIPNAME".signed "$ZIPNAME".fixed 1> /dev/null 2>&1
rm -f "$ZIPNAME".signed
java -Xmx"$JAVAHEAP" -jar "$MINSIGNAPK" "$TESTKEYPEM" "$TESTKEYPK8" "$ZIPNAME".fixed "$ZIPNAME"
rm -f "$ZIPNAME".fixed
mv -f "$ZIPNAME" "$FINALDIR"
ls | grep -iv "placeholder" | xargs rm -rf

# Define ending time
END=$(date +"%s")

# Done
clear
echo "All done creating GApps!"
echo "Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}') ($(echo "$END - $BEGIN" | bc) seconds)"
echo "Completed GApps zip is located in $FINALDIR"
cd ../
