//
//  Router.swift
//  DownloadVideos
//
//  Created by Monis Manzoor on 06/03/25.
//

import SwiftUI
import Foundation


class Router : ObservableObject  {
    @Published var navPath: NavigationPath = NavigationPath()
    
    func navigate(to video: Video) {
        navPath.append(video)
    }
    
    func navigateBack() {
        navPath.removeLast()
    }
    
    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}
