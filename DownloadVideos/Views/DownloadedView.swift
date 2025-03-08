//
//  DownloadedView.swift
//  DownloadVideos
//
//  Created by Monis Manzoor on 26/02/25.
//

import SwiftUI

struct DownloadedView: View {
    @EnvironmentObject var vm : DownloadViewModel
    @EnvironmentObject var router : Router
    
    var body: some View {
        NavigationView {
            List {
                if !vm.downloadMetaData.isEmpty {
                    DownloadingVideosView()
                }
                
                if !vm.pendingDownloads.isEmpty {
                    PendingView()
                }
                
                if !vm.downloadedFiles.isEmpty {
                    DownloadedVideosView()
                }
            }
            .navigationBarTitle(Text("All Videos"))
            .environmentObject(vm)
            .buttonStyle(.plain)
        }
        .onAppear {
            self.vm.getDownloadedFiles()
        }
    }
}

extension Double {
    var displayPercentage: String {
        return "\(Int(self))%"
    }
}

struct DownloadingVideosView : View {
    @EnvironmentObject var vm : DownloadViewModel
    
    var body: some View {
        
        Section(header: Text("Downloading Videos")) {
            ForEach(vm.downloadMetaData) { videoMetaData in
                HStack {
                    let video = vm.findVideoObject(ForVideo: URL(string: videoMetaData.videoURL)!.lastPathComponent)
                    AsyncImage(url: URL(string: video!.thumb)) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    } placeholder: {
                        ProgressView()
                    }
                    VStack(alignment: .leading) {
                        Text(video!.title)
                            .font(.headline)
                        ProgressView.init(value: videoMetaData.progress, total: 100)
                            .padding([.leading, .trailing], 0)
                        Text(videoMetaData.progress.displayPercentage)
                            .font(.headline)
                    }
                    Spacer()
                    Button(action: {
                        if videoMetaData.videoStatus == .Downloading {
                            vm.pauseDownload(videoMetaData.videoURL)
                        }
                        else {
                            vm.resumeDownload(videoMetaData.videoURL)
                        }
                        
                    }) {
                        Image(systemName: videoMetaData.videoStatus == .Downloading ? "pause.fill" : "play.fill")
                    }
                    .frame(width: 44, height: 44)
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct DownloadedVideosView : View {
    @EnvironmentObject var vm : DownloadViewModel
    
    var body: some View {
        Section(header: Text("Downloaded Videos")) {
            ForEach(vm.downloadedFiles, id : \.self.pathURL.lastPathComponent) { downloadedVideo in
                NavigationLink(destination: VideoView(videoURL: downloadedVideo.pathURL)) {
                    HStack(spacing : 10) {
                        AsyncImage(url: URL(string: downloadedVideo.thumb)) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        } placeholder: {
                            ProgressView()
                        }
                        Text(downloadedVideo.title)
                            .font(.headline)
                    }
                }
            }
            .onDelete(perform: delete(at:))
        }
    }
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            let file = vm.downloadedFiles[offset]
            vm.deleteItemAtPath(file.pathURL)
        }
    }
}

struct PendingView : View {
    @EnvironmentObject var vm : DownloadViewModel
    
    var body: some View {
        Section(header: Text("Pending Downloads")) {
            ForEach(vm.pendingDownloads, id: \.self) { videoURL in
                HStack {
                    let video = vm.findVideoObject(ForVideo: URL(string: videoURL)!.lastPathComponent)
                    AsyncImage(url: URL(string: video!.thumb)) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    } placeholder: {
                        ProgressView()
                    }
                    VStack(alignment: .leading) {
                        Text(video!.title)
                            .font(.headline)
                        Text("Queued")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    DownloadedView()
        .environmentObject(DownloadViewModel())
        .environmentObject(Router())
}
