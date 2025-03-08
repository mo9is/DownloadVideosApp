//
//  HomeView.swift
//  DownloadVideos
//
//  Created by Monis Manzoor on 26/02/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: DownloadViewModel
    @EnvironmentObject var router: Router
    
    var body: some View {
        TabView {
              ContentView()
                  .tabItem {
                      Label("Movies", systemImage: "popcorn.fill")
                  }

              DownloadedView()
                  .tabItem {
                      Label("Downloaded", systemImage: "arrowshape.down.circle")
                  }
          }.environmentObject(viewModel)
            .environmentObject(router)
    }
}

#Preview {
    HomeView()
        .environmentObject(DownloadViewModel())
}
