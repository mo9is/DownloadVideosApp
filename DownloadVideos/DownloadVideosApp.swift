//
//  DownloadVideosApp.swift
//  DownloadVideos
//
//  Created by Monis Manzoor on 25/02/25.
//

import SwiftUI

@main
struct DownloadVideosApp: App {
    @StateObject var viewModel = DownloadViewModel()
    @ObservedObject var router = Router()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navPath) {
                HomeView()
                    .navigationDestination(for: Video.self) { video in
                        VideoView(videoURL: URL(string: video.sources.first!)!)
                    }
            }
            .environmentObject(viewModel)
            .environmentObject(router)
        }
    }
}
