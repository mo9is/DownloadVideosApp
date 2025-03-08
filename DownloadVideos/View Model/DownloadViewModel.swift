//
//  DownloadVM.swift
//  DownloadVideos
//
//  Created by Monis Manzoor on 26/02/25.
//

import SwiftUI
import Combine

enum DownloadStateError : Error {
    case invalidData
    case invalidURL
    case badServerResponse
}


class DownloadViewModel : ObservableObject {
    @Published var categories : [Categories] = []
    private var cancellables : Set<AnyCancellable> = []
    private var downloadCancellables : Set<AnyCancellable> = []
    
    private let downloadManager = DownloadManager()
    @Published var downloadMetaData : Array<DownloadMetadata> = []
    @Published var downloadedFiles : Array<DownloadedVideo> = []
    
    @Published var pendingDownloads : Array<String> = []
    
    init () {
        fetchVideosData()
    }
    
    func fetchVideosData() {
        do {
            let sampleJSONData = try dataFromSampleJSOn()
            let passThroughSubject = PassthroughSubject<Data, Never>()
            passThroughSubject.decode(type: ResponseModel.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink { completion  in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] value in
                    self?.categories = value.categories
                    print("/**Data fetched \(self?.categories ?? [])")
                }
                .store(in: &cancellables)
            passThroughSubject.send(sampleJSONData)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func dataFromSampleJSOn() throws -> Data {
        guard let filePath = Bundle.main.url(forResource: "sample", withExtension: "json") else {
            throw DownloadStateError.invalidData
        }
        return try Data(contentsOf: filePath)
    }
    
    static func sampleVideo() -> Video {
        return Video(subtitle: "By Blender Foundation", description: "Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge.\n\nLicensed under the Creative Commons Attribution license\nhttp://www.bigbuckbunny.org", sources: ["https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"], thumb: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg", title: "Big Buck Bunny")
    }
}

extension DownloadViewModel {
    func downloadFileFromServer(_ url : String) {
        
        guard self.downloadManager.downloadingTasks.count == 0 else {
            self.pendingDownloads.append(url)
            return
        }
        
        self.downloadManager.downloadVideo(url) .receive(on: DispatchQueue.main)
            .sink { completion  in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
                if self.pendingDownloads.count > 0 {
                    self.downloadFileFromServer(self.pendingDownloads.first!)
                    self.pendingDownloads.removeFirst()
                }
            } receiveValue: { value in
                self.getDownloadedFiles()
                print("\(value)")
            }
            .store(in: &downloadCancellables)
        
        self.downloadManager.downloadCompletionHandler = { [weak self] dict in
            self?.downloadMetaData = dict
        }
    }
    func downloadInfo(forURL url : String) -> DownloadMetadata?  {
        let downloadMetaData = self.downloadMetaData.filter { $0.videoURL == url }
        if downloadMetaData.count > 0 {
            return downloadMetaData.first!
        }
        return nil
    }
    
    func findVideoObject(ForVideo name : String) -> Video? {
        for category in self.categories {
            for video in category.videos {
                if URL(string: video.sources.first!)!.lastPathComponent  == name {
                    return video
                }
            }
        }
        return nil
    }
    
    func getDownloadedFiles() {
        var files =  FileHandler.AllDownloadedFiles().map { destinationFileURL in
            if let video = self.findVideoObject(ForVideo: destinationFileURL.lastPathComponent) {
                let downloadVideo = DownloadedVideo.init(title: video.title, pathURL: destinationFileURL, thumb: video.thumb)
                return downloadVideo
            }
            else {
                let downloadVideo = DownloadedVideo.init(title: destinationFileURL.lastPathComponent, pathURL: destinationFileURL, thumb: "")
                return downloadVideo
            }
        }
        files.reverse( )
        self.downloadedFiles = files
    }
    
    func deleteItemAtPath(_ serverURL : URL) {
        FileHandler.deleteItemAtPath(serverURL) {
            self.getDownloadedFiles()
        }
    }
    
    func resumeDownload(_ videoURL : String) {
        self.downloadManager.resumeDownloadedvideo(ForVideo: videoURL)
    }
    
    func pauseDownload(_ videoURL : String) {
        self.downloadManager.pauseDownloadedVideo(ForVideo: videoURL)
    }
}
