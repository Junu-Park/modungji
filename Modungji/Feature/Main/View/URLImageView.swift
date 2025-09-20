//
//  URLImageView.swift
//  Modungji
//
//  Created by 박준우 on 7/25/25.
//

import SwiftUI

struct URLImageView<Placeholder: View>: View {
    @State private var uiImage: UIImage?
    
    private let urlString: String
    
    private let placeholder: Placeholder
    
    init(urlString: String, @ViewBuilder placeholder: () -> Placeholder) {
        self.urlString = urlString
        
        self.placeholder = placeholder()
    }
    
    var body: some View {
        ZStack {
            Group {
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                } else {
                    self.placeholder
                }
            }
        }
        .task(id: urlString) {
            if !self.urlString.isEmpty {
                self.uiImage = await ImageCacheManager.shared.getImage(urlString: urlString)
            }
        }
    }
}

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 50
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func getImage(urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)
        
        guard let cacheImage = cache.object(forKey: cacheKey) else {
            do {
                return try await getImageFromURL(urlString: urlString)
            } catch {
                return nil
            }
        }
        
        return cacheImage
    }
    
    func removeImage(urlString: String) {
        let cacheKey = NSString(string: urlString)
        
        cache.removeObject(forKey: cacheKey)
    }
    
    private func getImageFromURL(urlString: String) async throws -> UIImage? {
        let response = try await NetworkManager().requestEstate(requestURL: EstateRouter.File.file(urlString: urlString))
        
        switch response {
        case .success(let data):
            guard let image = UIImage(data: data) else {
                return nil
            }
            
            let cacheKey = NSString(string: urlString)
            cache.setObject(image, forKey: cacheKey)
            return image
        case .failure:
            return nil
        }
    }
}
