
//  Origial file:  https://github.com/stavares843/strings-sweeper/blob/main/strings-sweeper.swift
//  Modified by Abdulrahman Qasem on 9/10/2023.
//  Copyright © 2024 Baaz Inc. All rights reserved.

import Foundation

// Determines unused localization keys by scanning Swift files in the project
// Optionally removes unused keys from the specified language file
// Creates a backup of the original language file before removal // uncomment it if want to use it

/*
 usage:
 1- navigate to baaz base folder (main git folder where strings-sweeper.swift located)
 2- run the following command
 
 swift strings-sweeper.swift --langEnum /path/to/baaz/localization/enum/BZEnumerations.swift  --lang /path/to/localization/folder/Localization --remove
 
 in Abdulrahman case:
 ex:
 swift strings-sweeper.swift --langEnum /Users/abdulrahmanqasem/Desktop/Abdulrahman/baaz_ios_new/Baaz/Baaz/Helpers/BZEnumerations.swift  --lang /Users/abdulrahmanqasem/Desktop/Abdulrahman/baaz_ios_new/Baaz/BaaziOS/Resources/Localization --remove
 */

let args = CommandLine.arguments
var assetsFile = "./Assets.xcassets"
var shouldRemoveAssets = false

if args.contains("--assets") {
    if let index = args.firstIndex(of: "--assets"), index + 1 < args.count {
        assetsFile = args[index + 1]
    }
}

if args.contains("--remove") {
    shouldRemoveAssets = true
}


// Backup language file with a timestamp
func backupLanguageFile() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmss"
    let timestamp = dateFormatter.string(from: Date())
    let backupFile = assetsFile + ".bak" + timestamp
    do {
        try FileManager.default.copyItem(atPath: assetsFile, toPath: backupFile)
        print("Backup created: \(backupFile)")
    } catch {
        print("Error: Failed to create a backup of the language file.")
        exit(1)
    }
}

// Read the lang enum file
guard let assetsPaths = try? FileManager.default.subpathsOfDirectory(atPath: assetsFile) else {
    print("Error: Unable to read the assets file at \(assetsFile)")
    exit(1)
}
var imageNames = Set<String>()
var imagePaths:[(String,String)] = []

for assetPath in assetsPaths {
    if let url = URL(string: assetPath), assetPath.hasSuffix(".imageset") {
        let imageName = url.lastPathComponent.replacingOccurrences(of: ".imageset", with: "")
        imageNames.insert(imageName)
        imagePaths.append((imageName,"\(assetsFile)/\(assetPath)"))
    }
}
//print(Array(imageNames)[2])
//print(imagePaths[2])
//exit(1)

// Collect all Swift files
if let files = try? FileManager.default.subpathsOfDirectory(atPath: FileManager.default.currentDirectoryPath) {
    // Remove build files
    let filteredFiles = files.filter { ($0.hasSuffix(".swift") || $0.hasSuffix(".storyboard") || $0.hasSuffix(".xib")) }

    // Remove dynamically created keys, e.g., toast action keys
    //keys = keys.filter { !$0.hasPrefix("toast_actions") }

    // Check Swift files if the language key is used
    for file in filteredFiles {
        if let content = try? String(contentsOfFile: file) {
            imageNames = imageNames.filter { !content.contains("\($0)") }
        }
    }

    // Print unused keys
    let unusedImageNames = imageNames.joined(separator: "\n")
    print(unusedImageNames.isEmpty ? "No unused keys found." : "Unused keys:\n\(unusedImageNames)")

    if shouldRemoveAssets {
        // Filter out the lines with unused keys
        let pathsToDelete = imagePaths.filter { imageNames.contains($0.0) }.map { $0.1 }

        // Join the modified lines into a single string
        //let modifiedContent = modifiedLines.joined(separator: "\n")

        // Backup the original language file
        //backupLanguageFile()
        let fileManager = FileManager.default
        for path in pathsToDelete {
            do {
                try fileManager.removeItem(atPath: path)
                print("Folder deleted successfully")
            } catch {
                print("Error deleting folder: \(error.localizedDescription)")
                exit(1)
            }
        }
        // Write the modified content back to the language file
//        do {
//            try modifiedContent.write(toFile: assetsFile, atomically: false, encoding: .utf8)
//            print("Unused keys removed from \(assetsFile).")
//        } catch {
//            print("Error: Failed to write modified content back to the language file.")
//            exit(1)
//        }

    }
}


//var imageNames = Set<String>()
//var keys = Set<String>()
//var lines = [(String, String)]()
//var rootKey = ""
//
//langEnumContent.enumerateLines { line, _ in
//    let stripped = line.trimmingCharacters(in: .whitespaces)
//
//    if stripped.isEmpty {
//        lines.append(("", line))
//        return
//    }
//
//    var langKey = ""
//
//    if stripped.hasPrefix("case") {
//        let split = stripped.components(separatedBy: " ")
//        for componentIndex in 1..<(split.count) {
//            let component = split[componentIndex]
//            if !component.isEmpty && !component.hasPrefix(".") {
//                langKey = split[componentIndex]
//                keys.insert(langKey)
//                break
//            }
//        }
//    }
//    lines.append((langKey, line))
//}
//
//// Collect all Swift files
//if let files = try? FileManager.default.subpathsOfDirectory(atPath: FileManager.default.currentDirectoryPath) {
//    // Remove build files
//    let filteredFiles = files.filter { !$0.hasPrefix("target/") && $0.hasSuffix(".swift") }
//
//    // Remove dynamically created keys, e.g., toast action keys
//    keys = keys.filter { !$0.hasPrefix("toast_actions") }
//
//    // Check Swift files if the language key is used
//    for file in filteredFiles {
//        if let content = try? String(contentsOfFile: file) {
//            keys = keys.filter { !content.contains(".\($0)") }
//        }
//    }
//
//    // Print unused keys
//    let unusedKeys = keys.joined(separator: "\n")
//    print(unusedKeys.isEmpty ? "No unused keys found." : "Unused keys:\n\(unusedKeys)")
//
//    if shouldRemoveAssets {
//        // Filter out the lines with unused keys
//        let modifiedLines = lines.filter { !keys.contains($0.0) }.map { $0.1 }
//        
//        // Join the modified lines into a single string
//        let modifiedContent = modifiedLines.joined(separator: "\n")
//        
//        // Backup the original language file
//        //backupLanguageFile()
//        
//        // Write the modified content back to the language file
//        do {
//            try modifiedContent.write(toFile: assetsFile, atomically: false, encoding: .utf8)
//            print("Unused keys removed from \(assetsFile).")
//        } catch {
//            print("Error: Failed to write modified content back to the language file.")
//            exit(1)
//        }
//        
//    }
//}
//
//
