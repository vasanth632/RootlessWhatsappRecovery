# RootlessWhatsappRecovery

ABOUT THE PROJECT: 

This script retrieves the WhatsApp database file and the key file without rooting the Android device. This is done by installing the custom build WhatsApp version called Legacy WhatsApp and uninstalling the previously installed genuine WhatsApp. This script was build under the resources provided at the *Kerala Security Audit and Assurance Center (KSAAC)*. Extended thanks to the support by the KSAAC team. 

-----------------------------------------------------------------------------------------------------

BUILD WITH: 
1.	BASH (For Linux)
2.	PYTHON

DEPENDENCIES:
1.	JAVA
2.	ADB
3.	GREP
4.	CURL 
5.	TAR

PREREQUISITIES: 
1.	OS: Linux
2.	Python 3.x
3.	Java 
4.	USB Debugging must be enabled on the target device. Settings → Developer Options → USB debugging. 
5.	Android Device greater than Android 4.0. (Tested upto Android 7.1)

PROCEDURE: 
1.	Before running the script, take a backup of your current WhatsApp chats to prevent any unforeseen data loss. 
2.	Once the backup is completed, connect the Android device with the USB debugging mode enabled.
3.	Connect the device to the linux through the adb command 'adb connect <ip_address>'. After the successful connection, run the bash code script which initially takes backup of the currently installed WhatsApp.  
4.	Once the backup is completed, the currently installed WhatsApp is uninstalled. After the uninstallation, the modified version of the WhatsApp is installed through the adb. 
5.	This WhatsApp will fetch the key file and the database file from the '/data/data/com.whatsapp'. 

This procedure retrieves the WhatsApp database file which contains all the details of the entire chat 
of the WhatsApp in that particular device even the deleted messages. The main advantage of this method 
of retrieval is that this process requires no rooting of the device which is the main advantage. 

TROUBLESHOOTING: 

•	If you face any issues regarding the version mismatch of any dependencies, kindly install the latest patches of the particyular dependencies and replace those in the bin folder. 

•	If you face any Android version mismatch, kindly decompile the LegacyWhatsApp.apk and make modifications
in the yml file of the apk by changing the desired Android SDK version. 


