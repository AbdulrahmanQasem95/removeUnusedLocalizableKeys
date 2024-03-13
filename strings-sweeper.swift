
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
var LangEnumFile = "./BZEnumerations.swift"
var LangFiles:[String] = []
var shouldRemoveKeys = false

if args.contains("--langEnum") {
    if let index = args.firstIndex(of: "--langEnum"), index + 1 < args.count {
        LangEnumFile = args[index + 1]
    }
}

if args.contains("--lang") {
    if let index = args.firstIndex(of: "--lang"), index + 1 < args.count {
        appendStringsFiles(inPath:  args[index + 1], toArray: &LangFiles)
        LangFiles = Array(Set(LangFiles))
    }
}

if args.contains("--remove") {
    shouldRemoveKeys = true
}

func appendStringsFiles(inPath path:String, toArray array:inout [String] ) {
    if path.hasSuffix(".strings") {
        array.append(path)
    } else if let files = try? FileManager.default.subpathsOfDirectory(atPath: path) {
        for file in files.map({"\(path)/\($0)"}) {
            appendStringsFiles(inPath: file, toArray: &array)
        }
    }
}


// Backup language file with a timestamp
func backupLanguageFile() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmss"
    let timestamp = dateFormatter.string(from: Date())
    let backupFile = LangEnumFile + ".bak" + timestamp
    do {
        try FileManager.default.copyItem(atPath: LangEnumFile, toPath: backupFile)
        print("Backup created: \(backupFile)")
    } catch {
        print("Error: Failed to create a backup of the language file.")
        exit(1)
    }
}

// Read the lang enum file
guard let langEnumContent = try? String(contentsOfFile: LangEnumFile) else {
    print("Error: Unable to read the language file at \(LangEnumFile)")
    exit(1)
}
var keys = Set<String>()
var lines = [(String, String)]()
var rootKey = ""

langEnumContent.enumerateLines { line, _ in
    let stripped = line.trimmingCharacters(in: .whitespaces)

    if stripped.isEmpty {
        lines.append(("", line))
        return
    }

    var langKey = ""

    if stripped.hasPrefix("case") {
        let split = stripped.components(separatedBy: " ")
        for componentIndex in 1..<(split.count) {
            let component = split[componentIndex]
            if !component.isEmpty && !component.hasPrefix(".") {
                langKey = split[componentIndex]
                keys.insert(langKey)
                break
            }
        }
    }
    lines.append((langKey, line))
}

// Collect all Swift files
if let files = try? FileManager.default.subpathsOfDirectory(atPath: FileManager.default.currentDirectoryPath) {
    // Remove build files
    let filteredFiles = files.filter { !$0.hasPrefix("target/") && $0.hasSuffix(".swift") }

    // Remove dynamically created keys, e.g., toast action keys
    keys = keys.filter { !$0.hasPrefix("toast_actions") }

    // Check Swift files if the language key is used
    for file in filteredFiles {
        if let content = try? String(contentsOfFile: file) {
            keys = keys.filter { !content.contains(".\($0)") }
        }
    }

    // Print unused keys
    let unusedKeys = keys.joined(separator: "\n")
    print(unusedKeys.isEmpty ? "No unused keys found." : "Unused keys:\n\(unusedKeys)")

    if shouldRemoveKeys {
        // Filter out the lines with unused keys
        let modifiedLines = lines.filter { !keys.contains($0.0) }.map { $0.1 }
        
        // Join the modified lines into a single string
        let modifiedContent = modifiedLines.joined(separator: "\n")
        
        // Backup the original language file
        //backupLanguageFile()
        
        // Write the modified content back to the language file
        do {
            try modifiedContent.write(toFile: LangEnumFile, atomically: false, encoding: .utf8)
            print("Unused keys removed from \(LangEnumFile).")
            removeLinesInLangFiles()
        } catch {
            print("Error: Failed to write modified content back to the language file.")
            exit(1)
        }
        
    }
}

func removeLinesInLangFiles() {
    for file in LangFiles {
        
        guard let langFileContent = try? String(contentsOfFile: file) else {
            print("Error: Unable to read the language file at \(file)")
            return
        }
        
        var langFilelines = [(String, String)]()
        langFileContent.enumerateLines { line, _ in
            let stripped = line.trimmingCharacters(in: .whitespaces)
            
            if stripped.isEmpty {
                langFilelines.append(("", line))
                return
            }
            
            var langKey = ""
            
            if stripped.contains("=") {
                let split = stripped.components(separatedBy: "=")
                langKey = split[0].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")
            }
            langFilelines.append((langKey, line))
        }
        
        
        let modifiedLines = langFilelines.filter { !keys.contains($0.0) }.map { $0.1 }
        
        // Join the modified lines into a single string
        let modifiedContent = modifiedLines.joined(separator: "\n")
        
        // Backup the original language file
       // backupLanguageFile()
        
        // Write the modified content back to the language file
        do {
            try modifiedContent.write(toFile: file, atomically: false, encoding: .utf8)
            print("Unused keys removed from \(file).")
        } catch {
            print("Error: Failed to write modified content back to the language file.")
            exit(1)
        }
        
        
    }
}

