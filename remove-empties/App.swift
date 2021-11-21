//
//  App.swift
//  remove-empties
//
//  Created by Casey Liss on 2/6/20.
//  Copyright © 2020 Casey Liss. All rights reserved.
//

import Foundation

class App {
    
    var doDeletions = true
    var deletions = 0
    var errors = 0

    static func run(arguments: [String]) -> Int32 {
        return App().run(arguments)
    }
    
    func run(_ arguments: [String]) -> Int32 {
        if arguments.count < 2 {
            printUsage(appPath: CommandLine.arguments[0])
            return 1
        }
        
        if arguments[1].lowercased() == "--dry-run" {
            self.doDeletions = false
        }
        
        let rootUrl = URL(fileURLWithPath: NSString(string: CommandLine.arguments.last!).expandingTildeInPath)
        self.deleteEmpties(path: rootUrl)
        
        return 0
    }
    
    func deleteEmpties(path: URL) {
        let keys: [URLResourceKey] = [.isDirectoryKey, .isAliasFileKey, .isHiddenKey, .isSymbolicLinkKey]
        let c = try? FileManager.default.contentsOfDirectory(at: path,
                                                             includingPropertiesForKeys: keys,
                                                             options: .includesDirectoriesPostOrder)
        guard let contents = c else {
            return
        }
        
        if contents.count == 0 {
            print("\(path.path) \(self.doDeletions ? "was" : "would be") deleted")
            if self.doDeletions {
                do {
                    try FileManager.default.trashItem(at: path.standardizedFileURL, resultingItemURL: nil)
                    self.deletions += 1
                } catch {
                    print("⚠️ Could not delete \(path.path)")
                    self.errors += 1
                }
            }
        } else {
            for c in contents {
                self.deleteEmpties(path: c)
            }
        }
    }
    
    func printUsage(appPath: String) {
        let command = URL(fileURLWithPath: appPath).lastPathComponent
        print("\(command) {--dry-run} {root folder}")
        print()
        print("\t--dry-run:   Include if the empties should NOT be deleted")
        print("\tRoot folder: The place to start looking for empty folders")
    }

}
