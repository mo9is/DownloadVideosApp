//
//  DownloadManager.swift
//  DownloadVideos
//
//  Created by Monis Manzoor on 26/02/25.
//

import SwiftUI
import Combine

protocol DownloadManagerProtocol : AnyObject {
    func downloadVideo(_ downloadURL : String) -> Future<Bool, Error>
    func pauseDownloadedVideo(ForVideo videoURL : String)
    func resumeDownloadedvideo(ForVideo videoURL : String)
}

class DownloadManager : DownloadManagerProtocol {
    private let session : URLSession
    private var downloadObserver : NSKeyValueObservation?
    private var downloadInfo : Array<DownloadMetadata> = [] {
        didSet {
            DispatchQueue.main.async { [self] in
                self.downloadCompletionHandler?(downloadInfo)
            }
        }
    }
    var downloadingTasks : Array<URLSessionTask> = []
    
    var downloadCompletionHandler : ((Array<DownloadMetadata>) -> Void)?
    
    init(_ session : URLSession = .shared) {
        self.session = session
    }
    
    func downloadVideo(_ downloadURL : String) -> Future<Bool, Error> {
        guard let validURL = URL(string: downloadURL) else {
            return Future { result in
                result(.failure(DownloadStateError.invalidURL))
            }
        }
        
        guard FileHandler.isFileExistsAtPath(validURL) == false else {
            return Future { result in
                result(.success(true))
            }
        }
        
        self.addObjectForDownload(DownloadMetadata(videoURL: validURL.absoluteString, videoStatus: VideoDownloadStatus.Downloading, progress: 0))
                
        return Future { [weak self] result in
            
            let downloadDataTask =  self?.session.downloadTask(with: validURL, completionHandler: { (location,response,errror) in
                DispatchQueue.main.async {
                    if let response = response as? HTTPURLResponse, response.statusCode == 200, let location = location {
                        print(location.absoluteString)
                        FileHandler.loadFileSync(tempDestinationURL: location, serverURL: response.url!) { destionationURL, error in
                            if error == nil {
                                result(.success(true))
                            }
                            else {
                                result(.failure(error!))
                            }
                        }
                    }
                    else {
                        if let error = errror {
                            print("error in downloading from server \(error.localizedDescription)")
                            result(.failure(DownloadStateError.badServerResponse))
                        }
                        else {
                            result(.failure(DownloadStateError.badServerResponse))
                        }
                        
                    }
                    if let response = response as? HTTPURLResponse, let responseURL = response.url {
                        self?.removeValue(ForObjectURL: responseURL.absoluteString)
                        self?.removeDownloadedTask(responseURL.absoluteString)
                    }
                    else {
                        self?.downloadInfo.removeAll()
                        self?.downloadingTasks.removeAll()
                    }
                }
            })
            
            
            if let task = downloadDataTask {
                    self?.downloadingTasks.append(task)
                    task.resume()
            }
            
            self?.downloadObserver = downloadDataTask?.progress.observe(\.fractionCompleted) { [weak self] progress, _  in
                let progress = Double(progress.fractionCompleted * 100)
                if let downloadingURL = downloadDataTask?.response?.url {
                    let info = DownloadMetadata(videoURL: downloadingURL.absoluteString, videoStatus: .Downloading, progress: progress)
                    DispatchQueue.main.async {
                        self?.addObjectForDownload(info)
                        print("Here's the progress for download for object url : \(downloadingURL.lastPathComponent) - \(info.progress)")
                    }
                }
            }
        }
    }
    
    func pauseDownloadedVideo(ForVideo videoURL : String) {
        let task = self.downloadingTasks.filter { $0.response?.url?.absoluteString == videoURL }
        let filtered = self.downloadInfo.filter { $0.videoURL == videoURL }
        if task.count > 0 {
            task.first!.suspend()
        }
        if filtered.count > 0 {
            filtered.first!.videoStatus = .Pause
        }
        downloadCompletionHandler?(self.downloadInfo)
    }
    
    func resumeDownloadedvideo(ForVideo videoURL : String) {
        let task = self.downloadingTasks.filter { $0.response?.url?.absoluteString == videoURL }
        let filtered = self.downloadInfo.filter { $0.videoURL == videoURL }

        if task.count > 0 {
            task.first!.resume()
        }
        if filtered.count > 0 {
            filtered.first!.videoStatus = .Downloading
        }
        downloadCompletionHandler?(self.downloadInfo)
    }
    
    deinit {
        self.downloadObserver?.invalidate()
    }
}

extension DownloadManager {
    func removeValue(ForObjectURL videoURL : String) {
        let filter = self.downloadInfo.filter { $0.videoURL == videoURL}
        if filter.count > 0 {
            self.downloadInfo.removeAll { $0.videoURL == videoURL }
        }
    }
    
    func addObjectForDownload(_ object : DownloadMetadata) {
        if self.downloadInfo.count > 0 {
            let filter = self.downloadInfo.filter { $0.videoURL == object.videoURL}
            if filter.count > 0 {
                let existingObject = filter.first!
                existingObject.progress = object.progress
                self.downloadCompletionHandler?(self.downloadInfo)
            }
            else {
                self.downloadInfo.append(object)
            }
        }
        else {
            self.downloadInfo.append(object)
        }
    }
    
    func removeDownloadedTask(_ videoURL : String) {
        let tasks = self.downloadingTasks.filter { $0.response?.url?.absoluteString == videoURL }
        if tasks.count > 0 {
            let task = tasks.first!
            self.downloadingTasks.remove(at: self.downloadingTasks.firstIndex(of: task)!)
        }
    }
}
