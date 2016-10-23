#!/sbin/sh

#
# /system/addon.d/70-gapps.sh
#

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

# Execute
. /tmp/backuptool.functions

# Functions & variables
file_getprop() { grep "^$2" "$1" | cut -d= -f2; }

rom_build_prop=/system/build.prop

arch=$(file_getprop $rom_build_prop "ro.product.cpu.abi=")

list_files() {
cat <<EOF
  app/FaceLock/FaceLock.apk
  app/GoogleCalendarSyncAdapter/GoogleCalendarSyncAdapter.apk
  app/GoogleContactsSyncAdapter/GoogleContactsSyncAdapter.apk
  app/GoogleVrCore/GoogleVrCore.apk
  app/GoogleTTS/GoogleTTS.apk
  etc/permissions/com.google.android.camera.experimental2015.xml
  etc/permissions/com.google.android.camera.experimental2016.xml
  etc/permissions/com.google.android.dialer.support.xml
  etc/permissions/com.google.android.maps.xml
  etc/permissions/com.google.android.media.effects.xml
  etc/permissions/com.google.widevine.software.drm.xml
  etc/preferred-apps/google.xml
  etc/sysconfig/google.xml
  etc/sysconfig/google_build.xml
  etc/sysconfig/google_vr_build.xml
  etc/sysconfig/whitelist_com.android.omadm.service.xml
  framework/com.google.android.camera.experimental2015.jar
  framework/com.google.android.camera.experimental2016.jar
  framework/com.google.android.dialer.support.jar
  framework/com.google.android.maps.jar
  framework/com.google.android.media.effects.jar
  framework/com.google.widevine.software.drm.jar
  lib/libfacenet.so
  lib/libfilterpack_facedetect.so
  lib/libjni_latinime.so
  lib/libjni_latinimegoogle.so
  lib64/libfacenet.so
  lib64/libfilterpack_facedetect.so
  lib64/libjni_latinime.so
  lib64/libjni_latinimegoogle.so
  priv-app/ConfigUpdater/ConfigUpdater.apk
  priv-app/GoogleBackupTransport/GoogleBackupTransport.apk
  priv-app/GoogleFeedback/GoogleFeedback.apk
  priv-app/GoogleLoginService/GoogleLoginService.apk
  priv-app/GoogleOneTimeInitializer/GoogleOneTimeInitializer.apk
  priv-app/GooglePartnerSetup/GooglePartnerSetup.apk
  priv-app/GoogleServicesFramework/GoogleServicesFramework.apk
  priv-app/HotwordEnrollment/HotwordEnrollment.apk
  priv-app/Phonesky/Phonesky.apk
  priv-app/PrebuiltGmsCore/PrebuiltGmsCore.apk
  priv-app/SetupWizard/SetupWizard.apk
  priv-app/Velvet/Velvet.apk
  usr/srec/en-US/APP_NAME.fst
  usr/srec/en-US/APP_NAME.syms
  usr/srec/en-US/c_fst
  usr/srec/en-US/class_normalizer.mfar
  usr/srec/en-US/CLG.prewalk.fst
  usr/srec/en-US/commands.abnf
  usr/srec/en-US/compile_grammar.config
  usr/srec/en-US/config.pumpkin
  usr/srec/en-US/confirmation_bias.fst
  usr/srec/en-US/CONTACT_NAME.fst
  usr/srec/en-US/CONTACT_NAME.syms
  usr/srec/en-US/contacts.abnf
  usr/srec/en-US/contacts_bias.fst
  usr/srec/en-US/contacts_disambig.fst
  usr/srec/en-US/dict
  usr/srec/en-US/dictation.config
  usr/srec/en-US/dnn
  usr/srec/en-US/endpointer_dictation.config
  usr/srec/en-US/endpointer_model
  usr/srec/en-US/endpointer_model.mmap
  usr/srec/en-US/endpointer_voicesearch.config
  usr/srec/en-US/ep_portable_mean_stddev
  usr/srec/en-US/ep_portable_model.mmap
  usr/srec/en-US/g2p.data
  usr/srec/en-US/g2p_fst
  usr/srec/en-US/grammar.config
  usr/srec/en-US/graphemes.syms
  usr/srec/en-US/hmmlist
  usr/srec/en-US/hmm_symbols
  usr/srec/en-US/input_mean_std_dev
  usr/srec/en-US/lexicon.U.fst
  usr/srec/en-US/lstm_model.uint8.data
  usr/srec/en-US/magic_mic.config
  usr/srec/en-US/metadata
  usr/srec/en-US/monastery_config.pumpkin
  usr/srec/en-US/normalizer.mfar
  usr/srec/en-US/norm_fst
  usr/srec/en-US/offensive_word_normalizer.mfar
  usr/srec/en-US/offline_action_data.pb
  usr/srec/en-US/phonelist
  usr/srec/en-US/phonelist.syms
  usr/srec/en-US/phonemes.syms
  usr/srec/en-US/portable_lstm
  usr/srec/en-US/portable_meanstddev
  usr/srec/en-US/pumpkin.mmap
  usr/srec/en-US/rescoring.fst.louds
  usr/srec/en-US/semantics.pumpkin
  usr/srec/en-US/SONG_NAME.fst
  usr/srec/en-US/SONG_NAME.syms
  usr/srec/en-US/voice_actions.config
  usr/srec/en-US/voice_actions_compiler.config
  usr/srec/en-US/word_classifier
  usr/srec/en-US/wordlist.syms
  vendor/lib/libfrsdk.so
  vendor/lib64/libfrsdk.so
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/$FILE
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/$FILE $R
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    # Stub
  ;;
  post-restore)
    # Re-remove conflicting apks
    rm -rf /system/app/BrowserProviderProxy
    rm -rf /system/app/PartnerBookmarksProvider
    rm -rf /system/app/Provision
    rm -rf /system/app/QuickSearchBox
    rm -rf /system/priv-app/BrowserProviderProxy
    rm -rf /system/priv-app/PartnerBookmarksProvider
    rm -rf /system/priv-app/Provision
    rm -rf /system/priv-app/QuickSearchBox

    # Make required symbolic links
    if (echo "$arch" | grep -qi "armeabi"); then
      mkdir -p /system/app/FaceLock/lib/arm
      mkdir -p /system/app/LatinIME/lib/arm
      ln -sfn /system/lib/libfacenet.so /system/app/FaceLock/lib/arm/libfacenet.so
      ln -sfn /system/lib/libjni_latinime.so /system/app/LatinIME/lib/arm/libjni_latinime.so
      ln -sfn /system/lib/libjni_latinimegoogle.so /system/app/LatinIME/lib/arm/libjni_latinimegoogle.so
    elif (echo "$arch" | grep -qi "arm64"); then
      mkdir -p /system/app/FaceLock/lib/arm64
      mkdir -p /system/app/LatinIME/lib/arm64
      ln -sfn /system/lib64/libfacenet.so /system/app/FaceLock/lib/arm64/libfacenet.so
      ln -sfn /system/lib64/libjni_latinime.so /system/app/LatinIME/lib/arm64/libjni_latinime.so
      ln -sfn /system/lib64/libjni_latinimegoogle.so /system/app/LatinIME/lib/arm64/libjni_latinimegoogle.so
    fi
  ;;
esac
