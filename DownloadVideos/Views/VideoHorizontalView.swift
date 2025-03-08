//
//  MovieScrollView.swift
//  DownloadVideos
//
//  Created by Monis Manzoor on 26/02/25.
//

import SwiftUI
import AVKit

enum OptionSelection : String, CaseIterable {
    case Play
    case Download
    case Pause
    case Resume
    case Delete
}


struct VideoHorizontalView : View {
    var video : Video
    @State var isPresented : Bool = false
    @EnvironmentObject var vm : DownloadViewModel
    @EnvironmentObject var router : Router
    
    var body: some View {
        Button {
                isPresented.toggle()
            } label: {
                VStack {
                    AsyncImage(url: URL(string: video.thumb)!) { image in
                        image.resizable()
                            .frame(width: 150, height: 100)
                            .scaledToFit()
                            .cornerRadius(4)
                    } placeholder: {
                        ProgressView()
                    }
                    Text(video.title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
            .confirmationDialog("", isPresented: $isPresented) {
                ForEach(self.currentOptions(ForVideo: video), id : \.self.rawValue) { option in
                    Button(option.rawValue) {
                        self.buttonAction(forOption: option.rawValue, video: video)
                    }
                }
            }
    }
}

extension VideoHorizontalView {
            
    func buttonAction(forOption option : String, video : Video) {
        let option = OptionSelection(rawValue: option)
        
        if option == .Download {
            vm.downloadFileFromServer(video.sources.first!)
        }
        else if option == .Delete {
            vm.deleteItemAtPath(URL(string:video.sources.first!)!)
        }
        else if option == .Play {
            router.navigate(to: video)
        }
        else if option == .Pause {
            vm.pauseDownload(video.sources.first!)
            
        }
        else if option == .Resume {
            vm.resumeDownload(video.sources.first!)
        }
        
        self.isPresented = false
    }
        
    func currentOptions(ForVideo video : Video) -> [OptionSelection] {
        var modifiedList : Array<OptionSelection> = []
        modifiedList.append(.Play)
        
        let source = URL(string: video.sources.first ?? "")!
        
        guard FileHandler.isFileExistsAtPath(source) == false else {
            modifiedList.append(.Delete)
            return modifiedList
        }
        
        if let metaDataObject = vm.downloadInfo(forURL: video.sources.first!) {
            if metaDataObject.videoStatus == .Downloading {
                modifiedList.append(.Pause)
            }
            else if metaDataObject.videoStatus == .Pause {
                modifiedList.append(.Resume)
            }
            else {
                modifiedList.append(.Download)
            }
        }
        else {
            modifiedList.append(.Download)
        }
        return modifiedList
    }
}



#Preview {
    VideoHorizontalView(video: DownloadViewModel.sampleVideo(), isPresented: false)
        .environmentObject(DownloadViewModel())
}
