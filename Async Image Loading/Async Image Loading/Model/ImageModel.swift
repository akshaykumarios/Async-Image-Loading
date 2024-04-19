//
//  ImageModel.swift
//  Async Image Loading
//
//  Created by Akshay Kumar on 14/04/24.
//

import UIKit
import Foundation

struct APIEndpoint {
    static let baseUrl = "https://api.unsplash.com"
    static let getPhotos = "/photos?per_page=20&page="
}

enum Section {
    case main
}

struct RequestObj: Encodable, HttpRequestObj {
    let currentPage: Int
    
    var page: Int {
        return currentPage
    }
    var urlString: String {
        return APIEndpoint.getPhotos + "\(currentPage)"
    }
}

class Item: Decodable, Hashable {
    let identifier = UUID()
    let urls: ItemUrls
    var image: UIImage!
    
    init(urls: ItemUrls, image: UIImage) {
        self.urls = urls
        self.image = image
    }
    
    enum CodingKeys: String, CodingKey {
        case urls = "urls"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

struct ItemUrls: Decodable, Hashable {
    let smallS3: String
    var smallS3Url: URL {
        return URL(string: smallS3)!
    }
    
    enum CodingKeys: String, CodingKey {
        case smallS3 = "smallS3"
    }
}
