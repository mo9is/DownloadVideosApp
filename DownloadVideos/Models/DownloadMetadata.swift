//
//  DownloadInfo.swift
//  DownloadVideos
//
//  Created by MONIS MANZOOR on 28/02/25.
//

import SwiftUI

enum VideoDownloadStatus {
    case Downloading
    case Resume
    case Pause
    case unknown
}

class DownloadMetadata : Identifiable {
    var id : UUID = UUID()
    var videoURL : String = ""
    var videoStatus : VideoDownloadStatus = .unknown
    var progress : Double = 0.0
    
    init(videoURL: String, videoStatus: VideoDownloadStatus, progress: Double) {
        self.videoURL = videoURL
        self.videoStatus = videoStatus
        self.progress = progress
    }
}
