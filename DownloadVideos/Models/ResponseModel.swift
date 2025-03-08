//
//  ResponseModel.swift
//  DownloadVideos
//
//  Created by Monis Manzoor on 25/02/25.
//

import SwiftUI

struct ResponseModel : Codable {
    let categories: [Categories]
}

struct Categories : Codable {
    let name : String
    let videos : [Video]
}

struct Video : Codable, Hashable {
    let subtitle : String
    let description : String
    let sources : [String]
    let thumb : String
    let title : String
}
