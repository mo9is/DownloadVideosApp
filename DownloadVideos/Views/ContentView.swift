//
//  ContentView.swift
//  DownloadVideos
//
//  Created by Monis Manzoor on 25/02/25.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var vm : DownloadViewModel
    @EnvironmentObject var router : Router
    
    var body: some View {
            GeometryReader { geometry in
                    LazyVStack(alignment: .leading) {
                        ForEach(vm.categories, id: \.self.name) { category in
                            Text(category.name)
                                .font(.system(size: 30, weight: .bold))
                                .padding(.top)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(category.videos, id: \.self.title) { video in
                                            VideoHorizontalView(video: video)
                                                .environmentObject(vm)
                                                .environmentObject(router)
                                                .frame(width: 150, height: 150)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .frame(minHeight : geometry.size.height, alignment : .top)
                    .padding()
                }
    }
}

extension ContentView {
    func videoURLForView(_ video : Video) -> URL? {
        return URL(string: video.sources.first!)
    }
}

#Preview {
    ContentView()
        .environmentObject(DownloadViewModel())
}
