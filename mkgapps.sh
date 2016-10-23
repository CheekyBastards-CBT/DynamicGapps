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

# Usage:
# $ (source|bash|.) mkgapps.sh
# $ (source|bash|.) mkgapps.sh <mini|full|both>
# If you omit the parameters, an interactive menu will prompt you for them
# If you want to automate this script in your work flow, provide the parameters

# Define paths & variables
TARGETDIR=$(pwd)
BASE="$TARGETDIR"/base
FULL="$TARGETDIR"/full
MINI="$TARGETDIR"/mini
TOOLSDIR="$TARGETDIR"/tools
STAGINGDIR="$TARGETDIR"/staging
FINALDIR="$TARGETDIR"/out
ZIPNAMEFULL=Full_Dynamic_GApps-7.x.x-$(date +"%Y%m%d").zip
ZIPNAMEMINI=Mini_Dynamic_GApps-7.x.x-$(date +"%Y%m%d").zip
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

FULLAPPS="camera/arm/app/GoogleCamera
         camera/arm64/app/GoogleCamera
         facelock/arm/app/FaceLock
         googlevrcore/arm/app/GoogleVrCore
         googlevrcore/arm64/app/GoogleVrCore
         hangouts/arm/app/Hangouts
         hangouts/arm64/app/Hangouts
         photos/arm/app/Photos
         photos/arm64/app/Photos
         prebuiltbugle/arm/app/PrebuiltBugle
         prebuiltbugle/arm64/app/PrebuiltBugle
         prebuiltgmscore/arm/priv-app/PrebuiltGmsCore
         prebuiltgmscore/arm64/priv-app/PrebuiltGmsCore
         setupwizard/phone/priv-app/SetupWizard
         setupwizard/tablet/priv-app/SetupWizard
         system/app/CalendarGooglePrebuilt
         system/app/GoogleContactsSyncAdapter
         system/app/GoogleTTS
         system/app/PrebuiltDeskClockGoogle
         system/app/talkback
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

# Flags
MAKE_MINI=false
MAKE_FULL=false

# Parameter/menu logic
# If the user wants to specific the GApps they want as parameters, they can
# Otherwise, they will be provided a menu to make their selection
if [[ -z ${1} ]]; then
   echo "${red}==============================================${reset}"
   echo "${red}==${reset}${green}               Dynamic GApps              ${reset}${red}==${reset}"
   echo "${red}==${reset}${green}          Google Apps for arm/arm64       ${reset}${red}==${reset}"
   echo "${red}==============================================${reset}"
   echo "${red}==${reset}${yellow}   1 - Full GApps                         ${reset}${red}==${reset}"
   echo "${red}==${reset}${yellow}   2 - Mini GApps                         ${reset}${red}==${reset}"
   echo "${red}==${reset}${yellow}   3 - Both GApps                         ${reset}${red}==${reset}"
   echo "${red}==${reset}${yellow}   0 - Exit                               ${reset}${red}==${reset}"
   echo "${red}==============================================${reset}"
   echo ""
   echo -n "Enter selection: "
   read menu

   case "${menu}" in
      "1")
         MAKE_FULL=true ;;
      "2")
         MAKE_MINI=true ;;
      "3")
         MAKE_FULL=true
         MAKE_MINI=true ;;
      "0")
         exit ;;
      *)
         echo "Invalid selection! Please run the script again." && exit ;;
   esac
else
   while [[ $# -ge 1 ]]; do
      case "${1}" in
         "full")
            MAKE_FULL=true ;;
         "mini")
            MAKE_MINI=true ;;
         "both")
            MAKE_FULL=true
            MAKE_MINI=true ;;
         *)
            echo "Invalid parameter! Please run the script again and either specify mini, full, or both." && exit ;;
      esac

      shift
   done
fi

if [[ "${MAKE_FULL}" = true ]]; then
   # Start Full
   echo ""; echo "Making Full Dynamic GApps!"; echo ""

   BEGIN=$(date +%s)
   export PATH="$TOOLSDIR":$PATH
   cp -rf "$BASE"/* "$STAGINGDIR"
   cp -rf "$FULL"/* "$STAGINGDIR"

   for dirs in $FULLAPPS; do
     cd "$STAGINGDIR/${dirs}";
     dcapk 1> /dev/null 2>&1;
   done

   cd "$STAGINGDIR"
   zip -qr9 "$ZIPNAMEFULL" ./* -x "placeholder"
   java -Xmx"$JAVAHEAP" -jar "$SIGNAPK" -w "$TESTKEYPEM" "$TESTKEYPK8" "$ZIPNAMEFULL" "$ZIPNAMEFULL".signed
   rm -f "$ZIPNAMEFULL"
   zipadjust "$ZIPNAMEFULL".signed "$ZIPNAMEFULL".fixed 1> /dev/null 2>&1
   rm -f "$ZIPNAMEFULL".signed
   java -Xmx"$JAVAHEAP" -jar "$MINSIGNAPK" "$TESTKEYPEM" "$TESTKEYPK8" "$ZIPNAMEFULL".fixed "$ZIPNAMEFULL"
   rm -f "$ZIPNAMEFULL".fixed
   rm -f "$FINALDIR"/Full_*.zip
   mv -f "$ZIPNAMEFULL" "$FINALDIR"
   ls | grep -iv "placeholder" | xargs rm -rf
   cd ../

   if [[ -f ${FINALDIR}/${ZIPNAMEFULL} ]]; then
      # Finish Full
      END=$(date +%s)
      echo "${green}Full Gapps Complete!!${reset}"; echo ""
      echo "${green}Total time elapsed: $( echo $(( ${END}-${BEGIN} )) | awk '{print int($1/60)"mins "int($1%60)"secs "}' )${reset}"
      echo "${green}Zip location: ${FINALDIR}${reset}"
      echo "${green}Zip size: $( du -h ${FINALDIR}/${ZIPNAMEFULL} | awk '{print $1}' )${reset}"
   else
      echo "${red}GApps compilation failed!${reset}"
   fi
fi

if [[ "${MAKE_MINI}" = true ]]; then
   # Start Mini
   echo ""; echo "Making Mini Dynamic GApps!"; echo ""

   BEGIN=$(date +%s)
   export PATH="$TOOLSDIR":$PATH
   cp -rf "$BASE"/* "$STAGINGDIR"
   cp -rf "$MINI"/* "$STAGINGDIR"

   for dirs in $MINIAPPS; do
     cd "$STAGINGDIR/${dirs}";
     dcapk 1> /dev/null 2>&1;
   done

   cd "$STAGINGDIR"
   zip -qr9 "$ZIPNAMEMINI" ./* -x "placeholder"
   java -Xmx"$JAVAHEAP" -jar "$SIGNAPK" -w "$TESTKEYPEM" "$TESTKEYPK8" "$ZIPNAMEMINI" "$ZIPNAMEMINI".signed
   rm -f "$ZIPNAMEMINI"
   zipadjust "$ZIPNAMEMINI".signed "$ZIPNAMEMINI".fixed 1> /dev/null 2>&1
   rm -f "$ZIPNAMEMINI".signed
   java -Xmx"$JAVAHEAP" -jar "$MINSIGNAPK" "$TESTKEYPEM" "$TESTKEYPK8" "$ZIPNAMEMINI".fixed "$ZIPNAMEMINI"
   rm -f "$ZIPNAMEMINI".fixed
   rm -f "$FINALDIR"/Mini_*.zip
   mv -f "$ZIPNAMEMINI" "$FINALDIR"
   ls | grep -iv "placeholder" | xargs rm -rf
   cd ../

   if [[ -f ${FINALDIR}/${ZIPNAMEMINI} ]]; then
      # Finish Mini
      END=$(date +%s)
      echo "${green}Mini Gapps Complete!!${reset}"; echo ""
      echo "${green}Total time elapsed: $( echo $(( ${END}-${BEGIN} )) | awk '{print int($1/60)"mins "int($1%60)"secs "}' )${reset}"
      echo "${green}Zip location: ${FINALDIR}${reset}"
      echo "${green}Zip size: $( du -h ${FINALDIR}/${ZIPNAMEMINI} | awk '{print $1}' )${reset}"
   else
      echo "${red}GApps compilation failed!${reset}"
   fi
fi
