//
//  FileManager.swift
//  DownloadVideos
//
//  Created by Monis Manzoor on 27/02/25.
//

import SwiftUI
import Foundation

class FileHandler {
    
    static func loadFileSync(tempDestinationURL: URL, serverURL : URL, completion: @escaping (String?, Error?) -> Void) {
            let destinationUrl = self.getFilePathForFolder().appendingPathComponent(serverURL.lastPathComponent)

           if FileManager().fileExists(atPath: destinationUrl.path)
           {
               print("File already exists [\(destinationUrl.path)]")
               completion(destinationUrl.path, nil)
           }
           else if let dataFromURL = NSData(contentsOf: tempDestinationURL)
           {
               if dataFromURL.write(to: destinationUrl, atomically: true)
               {
                   print("file saved [\(destinationUrl.path)]")
                   completion(destinationUrl.path, nil)
               }
               else
               {
                   print("error saving file")
                   let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                   completion(destinationUrl.path, error)
               }
           }
           else
           {
               let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
               completion(destinationUrl.path, error)
           }
       }
    
    static func getFilePathForFolder() -> URL {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let downloadedVideoFolder =  documentsUrl.appendingPathComponent("Downloaded Videos")
        do {
            try FileManager.default.createDirectory(atPath: downloadedVideoFolder.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
        return downloadedVideoFolder
    }
    
    static func isFileExistsAtPath(_ serverURL: URL) -> Bool {
        let destinationUrl = self.getFilePathForFolder().appendingPathComponent(serverURL.lastPathComponent)
        if FileManager().fileExists(atPath: destinationUrl.path) {
            return true
        }
        return false
    }
    
    static func deleteItemAtPath(_ serverURL : URL, completionHandler: (() -> Void)? = nil) {
        let destinationUrl = self.getFilePathForFolder().appendingPathComponent(serverURL.lastPathComponent)
        do {
           try FileManager.default.removeItem(atPath: destinationUrl.path)
        }
        catch {
            print(error.localizedDescription)
        }
        completionHandler?()
    }
    
    static func AllDownloadedFiles() -> [URL] {
        do {
            let fileUrls = try FileManager.default.contentsOfDirectory(at: getFilePathForFolder(), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return fileUrls
        }
        catch {
            print(error.localizedDescription)
            return []
        }
    }
}
