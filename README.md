# SchoolDiary Payment Page

This project includes a page for the SchoolDiary app that lets user(parent) view various fees due for and paid by them.\
This project is build on MVVM architecture with:
> Data layer/Model
## 1.`academic_year_model`:
contains the dart model of **academic year** field of JSON file.\
Also includes `PaymentModel`.
## 2.`payment_model`:
contains the dart model of payment field of JSON file.
> Presentation layer/View
## UI Layer: `fee_screen`
> Business logic layer/ViewModel
## 1.`fee_view_model`
## 2.`due_fee_view_model`
## 3.`paid_fee_view_model`


# Software Details
Flutter version: 3.32.3\
Dart version: 3.8.1\
Android SDK version 36.0.0\
version 2025.1.1

# pubs/dependencies

**_Intl package:-_**\
    Documentation:\
        https://pub.dev/packages/intl\
    Version: ^0.20.2\
    Purpose: To use the DateFormat class to work with different forms of dates.(Internationalization for Dart) .

**_Path Provider:-_**\
    Documentation:\
        https://pub.dev/packages/path_provider\
    Version: ^2.1.5\
    Purpose: For finding commonly used locations on the filesystem.
             Here using getApplicationDocumentsDirectory().

**_Flutter Launcher Icon:-_**\
    Documentation:\
        https://pub.dev/packages/flutter_launcher_icons\
    Version: ^0.14.4\
    Purpose: To change the launcher icon

**_Provider:-_**\
    Documentation:\
        https://pub.dev/packages/provider
    Version: ^6.1.5\
    Purpose: For using ChangeNotifier.
    
# assets

For JSON file:- "../assets/dataFile.json"\
For launch icon:- "../assets/schooldiary.png"
