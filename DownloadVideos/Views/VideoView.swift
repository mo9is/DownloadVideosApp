//
//  VideoView.swift
//  DownloadVideos
//
//  Created by Monis Manzoor on 06/03/25.
//

import SwiftUI
import AVKit

struct VideoView: View {
    let videoURL : URL
    let player = AVPlayer()
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear{
              if player.currentItem == nil {
                  let item = AVPlayerItem(url: videoURL)
                    player.replaceCurrentItem(with: item)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    player.play()
                })
            }
    }
}

#Preview {
    VideoView(videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
}
