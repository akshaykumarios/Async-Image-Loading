//
//  ImageCache.swift
//  Async Image Loading
//
//  Created by Akshay Kumar on 14/04/24.
//

import UIKit
import Foundation

final class ImageCache {
    static let shared = ImageCache()
    
    var placeholderImage = UIImage(systemName: "photo")
    private let cachedImages = NSCache<NSURL, UIImage>()
    private var loadingResponses = [NSURL: [(Item, UIImage?) -> ()]]()
    
    final private func image(from url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    final func loadImage(from url: NSURL, for item: Item, completion: @escaping (Item, UIImage?) -> ()) {
        if let cachedImage = image(from: url) {
            DispatchQueue.main.async {
                completion(item, cachedImage)
            }
            return
        }
        
        if loadingResponses[url] != nil {
            loadingResponses[url]?.append(completion)
            return
        } else {
            loadingResponses[url] = [completion]
        }
        let urlRequest = URLRequest(url: url as URL)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let responseData = data,
                    let image = UIImage(data: responseData),
                  let blocks = self.loadingResponses[url],
                  error == nil else {
                DispatchQueue.main.async {
                    completion(item, nil)
                }
                return
            }
            self.cachedImages.setObject(image, forKey: url, cost: responseData.count)
            blocks.forEach { block in
                DispatchQueue.main.async {
                    block(item, image)
                }
                return
            }
        }.resume()
    }
}
