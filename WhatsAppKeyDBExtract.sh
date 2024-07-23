#!/usr/bin/env bash

tput bold;
tput setaf 2;
is_adb=1
[[ -z $(which adb) ]] && { is_adb=0; }
is_curl=1
[[ -z $(which curl) ]] && { is_curl=0; }
is_grep=1
[[ -z $(which grep) ]] && { is_grep=0; }
is_java=1
[[ -z $(which java) ]] && { is_java=0; }
is_tar=1
[[ -z $(which tar) ]] && { is_tar=0; }
is_tr=1
[[ -z $(which tr) ]] && { is_tr=0; }

echo -e "
=========================================================================
This tool will extract the WhatsApp Key file and msgstore.db file. To perform 
this, follow the following steps:
1. Connect the Androi devices with USB debugging mode enabled. 
2. Run the script
3. It will uninstall the current Whatsapp and re-install the modified WhatsApp.
4. Now it prompts for the baclup password and leave the password as bland
5. It will now extract the files and stores in a separate folder.
=========================================================================
"
#Checks whether adb is installed or not.
if (($is_adb == 0)); then
echo -e "\e[0;33m Error: adb is not installed - please install adb and run again!\e[0m"
#Checks whether curl is installed or not.
elif (($is_curl == 0)); then
echo -e "\e[0;33m Error: curl is not installed - please install curl and run again!\e[0m"
#Checks whether grep is installed or not.
elif (($is_grep == 0)); then
echo -e "\e[0;33m Error: grep is not installed - please install grep and run again!\e[0m"
#Checks whether java is installed or not.
elif (($is_java == 0)); then
echo -e "\e[0;33m Error: java is not installed - please install java and run again!\e[0m"
#Checks whether tar is installed or not.
elif (($is_tar == 0)); then
echo -e "\e[0;33m Error: tar is not installed - please install tar and run again!\e[0m"
#Checks whether tr is installed or not.
elif (($is_tr == 0)); then
echo -e "\e[0;33m Error: tr is not installed - please install tr and run again!\e[0m"
else
#Start of the script
echo -e "\n Starting the script.\n"
echo -e "\n Please connect the Android device and enable the USB debugging mode on. \n"
adb kill-server
adb start-server
adb wait-for-device
sdkver=$(adb shell getprop ro.build.version.sdk | tr -d '[[:space:]]')
sdpath=$(adb shell "echo \$EXTERNAL_STORAGE/WhatsApp/Databases/.nomedia" | tr -d '[[:space:]]')
if [ $sdkver -le 13 ]; then
echo -e "\nUnsupported Android Version - this method only works on 4.0 or higher :/\n"
adb kill-server
else
apkpath=$(adb shell pm path com.whatsapp | grep package | tr -d '[[:space:]]')
version=$(adb shell dumpsys package com.whatsapp | grep versionName | tr -d '[[:space:]]')
apkflen=$(curl -sI http://www.cdn.whatsapp.net/android/2.11.431/WhatsApp.apk | grep Content-Length | grep -o '[0-9]*')
if [ $apkflen -eq 18329558 ]; then
apkfurl=http://www.cdn.whatsapp.net/android/2.11.431/WhatsApp.apk
else
apkfurl=http://whatcrypt.com/WhatsApp-2.11.431.apk
fi
#Locating the Legacy WhatsApp
apkname=$(basename  ${apkpath/package:/})
if [ ! -f tmp/LegacyWhatsApp.apk ]; then
echo -e "\nDownloading legacy WhatsApp \n"
curl -o tmp/LegacyWhatsApp.apk $apkfurl
echo -e ""
else
echo -e "\nLegacy WhatsApp Found. \n"
fi
if [ -z "$apkpath" ]; then
echo -e "\nWhatsApp is not installed \nExiting ..."
else
echo -e "WhatsApp ${version/versionName=/} installed\n"
if [ $sdkver -ge 11 ]; then
adb shell am force-stop com.whatsapp
else
adb shell am kill com.whatsapp
fi
#Backup of current WhatsApp is being taken to prevent data loss
echo -e "Backing up WhatsApp ${version/versionName=/}"
adb pull ${apkpath/package:/} tmp
echo -e "Backup complete\n"
if [ $sdkver -ge 23 ]; then
#Deleting the currently installed WhatsApp
echo -e "Removing WhatsApp ${version/versionName=/} skipping data"
adb shell pm uninstall -k com.whatsapp
echo -e "Removal complete\n"
fi

sdkver=25

# Define the path to the legacy WhatsApp APK
legacy_whatsapp_apk="tmp/LegacyWhatsApp.apk"

# Uninstall the current WhatsApp if it exists once again
echo -e "Uninstalling existing WhatsApp..."
adb uninstall com.whatsapp

# Install the legacy WhatsApp
echo -e "Installing legacy WhatsApp "
if [ $sdkver -ge 17 ]; then
    adb install -r -d $legacy_whatsapp_apk
else
    adb install -r $legacy_whatsapp_apk
fi

# Check if the installation was successful
if [ $? -eq 0 ]; then
    echo -e "Install complete\n"
else
    echo -e "Installation failed\n"
    exit 1
fi

# Perform a backup based on SDK version
echo -e "Backing up WhatsApp data..."
if [ $sdkver -ge 23 ]; then
    adb backup -f tmp/whatsapp.ab com.whatsapp
else
    adb backup -f tmp/whatsapp.ab -noapk com.whatsapp
fi

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo -e "Backup complete\n"
else
    echo -e "Backup failed\n"
    exit 1
fi
if [ -f tmp/whatsapp.ab ]; then
echo -e "\nLeave the backup password empty press Enter: "
read password
java -jar bin/abe.jar unpack tmp/whatsapp.ab tmp/whatsapp.tar $password
tar xvf tmp/whatsapp.tar -C tmp apps/com.whatsapp/f/key
tar xvf tmp/whatsapp.tar -C tmp apps/com.whatsapp/db/msgstore.db
#Retrieving the files to the folder
echo -e "\nFetching the key file..."
cp tmp/apps/com.whatsapp/f/key extracted/whatsapp.cryptkey
echo -e "Fetching the msgstore.db ..."
cp tmp/apps/com.whatsapp/db/msgstore.db extracted/msgstore.db
echo -e "\nSaving the files to the folder"
adb push tmp/apps/com.whatsapp/f/key $sdpath
else
echo -e "Operation failed"
fi
if [ ! -f tmp/$apkname ]; then
#Restoring with the orginal WhatsApp
echo -e "\nDownloading WhatsApp ${version/versionName=/} to local folder\n"
curl -o tmp/$apkname http://www.cdn.whatsapp.net/android/${version/versionName=/}/WhatsApp.apk
fi
echo -e "\nRestoring WhatsApp ${version/versionName=/}"
if [ $sdkver -ge 17 ]; then
adb install -r -d tmp/$apkname
else
adb install -r tmp/$apkname
fi
#Cleraing the temporary files
echo -e "Restore complete\n\nCleaning up temporary files ..."
rm tmp/whatsapp.ab
rm tmp/whatsapp.tar
rm -rf tmp/apps
rm tmp/$apkname
echo -e "Done\n\nOperation complete\n"
fi
fi
fi
adb kill-server
read -p "Please press Enter to quit..."
exit 0
