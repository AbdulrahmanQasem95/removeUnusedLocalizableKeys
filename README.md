
## Introduction
This script is designed to work in a specific case 
when you have an enum to access localizble files as a buffer layer 

#### for example: 

in **ConstantTexts.swift**
```swift
enum ConstantTexts: String {
    case mainScreenTitle = "main_screen_title"
}
```

in **Base.lproj/Localizable.strings**
```swift
"main_screen_title" = "Your app title";
```

in **ar.lproj/Localizable.strings**
```swift
"main_screen_title" = "عنوان التطبيق";
```
and so on for other languages 


## Description

- Determines unused localization keys by scanning Swift files in the project.
- Optionally removes unused keys from the specified language file.
- Creates a backup of the original language file before removal.


### Prerequisites

- Swift installed on your machine.

### Running the Script

1. add strings-sweeper.swift anywhere 
2. open terminal
3. change directory to the folder where you add strings-sweeper.swift <br>(`cd path/to/strings-sweeper.swift`)
4. run the following command after replacing paths with your paths: <br> `swift strings-sweeper.swift --langEnum **/path/to/localization/enum/ConstantTexts.swift**  --lang **/path/to/localization/folder/Localization** --remove`


Replace `/path/to/localization/enum/ConstantTexts.swift` with the actual path to your enumKyes.strings file.<br>
Replace `/path/to/localization/folder/Localization` with the actual path to your localizable folder.<br>

The `--remove` flag is optional and will automatically remove unused keys from the file.

#### for example: 
`swift strings-sweeper.swift --langEnum /Users/abdulrahmanqasem/Desktop/Abdulrahman/baaz_ios_new/Baaz/Baaz/Helpers/ConstantTexts.swift  --lang /Users/abdulrahmanqasem/Desktop/Abdulrahman/baaz_ios_new/Baaz/BaaziOS/Resources/Localization --remove`


inspired by: [Strings Sweeper](https://github.com/stavares843/strings-sweeper)

سخ 
