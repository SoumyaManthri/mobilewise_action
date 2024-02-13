# mobileWISE

Flutter project for the mobileWISE application.

## Terminal commands

flutter build apk -t lib/main_dev.dart --flavor DEV
--> To build APK, change the main file and flavor accordingly

flutter build appbundle -t lib/main_dev.dart --flavor DEV
--> To build app bundle, change the main file and flavor accordingly

flutter pub run build_runner build --delete-conflicting-outputs
--> After making changes to Hive adapters

flutter packages pub run build_runner build --delete-conflicting-outputs
--> When adding/editing TypeAdapters for Hive