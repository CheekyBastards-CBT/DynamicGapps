#!/usr/bin/env bash

# Copyright (C) 2016 BeansTown106
# Portions Copyright (C) 2016 MrBaNkS
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Define paths & variables
TARGETDIR=$(pwd)
BASE="$TARGETDIR"/base
MINI="$TARGETDIR"/mini
TOOLSDIR="$TARGETDIR"/tools
STAGINGDIR="$TARGETDIR"/staging
FINALDIR="$TARGETDIR"/out
ZIPNAMEMIN=Mini_Dynamic_GApps-7.x.x-$(date +"%Y%m%d").zip
JAVAHEAP=3072m
SIGNAPK="$TOOLSDIR"/signapk.jar
MINSIGNAPK="$TOOLSDIR"/minsignapk.jar
TESTKEYPEM="$TOOLSDIR"/testkey.x509.pem 
TESTKEYPK8="$TOOLSDIR"/testkey.pk8
MINIAPPS="facelock/arm/app/FaceLock
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

# Colors
green=`tput setaf 2`
red=`tput setaf 1`
yellow=`tput setaf 3`
reset=`tput sgr0`

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

# Menu Options
menu=
until [ "$menu" = "0" ]; do
echo "${red}==============================================${reset}"
echo "${red}==${reset}${green}               Dynamic GApps              ${reset}${red}==${reset}"
echo "${red}==${reset}${green}          Google Apps for arm/arm64       ${reset}${red}==${reset}"
echo "${red}==============================================${reset}"
echo "${red}==${reset}${yellow}   1 - Mini GApps                         ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   2 - Full GApps                         ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   0 - Exit                               ${reset}${red}==${reset}"
echo "${red}==============================================${reset}"
echo ""
echo -n "Enter selection: "
read menu
echo ""
case ${menu} in

# Mini GApps
1 )
# Start Mini
BEGIN=$(date +%s)
export PATH="$TOOLSDIR":$PATH
cp -rf "$BASE"/* "$STAGINGDIR"
cp -rf "$MINI"/* "$STAGINGDIR"

for dirs in $MINIAPPS; do
  cd "$STAGINGDIR/${dirs}";
  dcapk 1> /dev/null 2>&1;
done

cd "$STAGINGDIR"
zip -qr9 "$ZIPNAMEMIN" ./* -x "placeholder"
java -Xmx"$JAVAHEAP" -jar "$SIGNAPK" -w "$TESTKEYPEM" "$TESTKEYPK8" "$ZIPNAMEMIN" "$ZIPNAMEMIN".signed
rm -f "$ZIPNAMEMIN"
zipadjust "$ZIPNAMEMIN".signed "$ZIPNAMEMIN".fixed 1> /dev/null 2>&1
rm -f "$ZIPNAMEMIN".signed
java -Xmx"$JAVAHEAP" -jar "$MINSIGNAPK" "$TESTKEYPEM" "$TESTKEYPK8" "$ZIPNAMEMIN".fixed "$ZIPNAMEMIN"
rm -f "$ZIPNAMEMIN".fixed
mv -f "$ZIPNAMEMIN" "$FINALDIR"
ls | grep -iv "placeholder" | xargs rm -rf
cd ../

# Finish Mini
END=$(date +%s)
echo "${green}Mini Gapps Complete!!${reset}"
echo "${green}Total time elapsed: $(echo $((${END}-${BEGIN})) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
echo "${green}Completed GApps Zip will be in $FINALDIR ${reset}"
;;
#############################################################

# Full GApps
2 )
echo "${green}Coming Soon!!${reset}"
;;
#############################################################

# Exit/Wrong choice
0 ) exit ;;
* ) echo "Wrong Choice, 1, 2 or 0 to exit"
    esac
done
;;
#############################################################
