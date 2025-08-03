//
//  URLImageView.swift
//  Modungji
//
//  Created by 박준우 on 7/25/25.
//

import SwiftUI

struct URLImageView: View {
    @State private var uiImage: UIImage?
    @State private var isLoading: Bool = true
    private let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else if isLoading {
                ProgressView()
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(.brightCream)
            }
        }
        .task {
            defer { isLoading = false }
            do {
                let response = try await NetworkManager().requestEstate(requestURL: EstateRouter.Image.image(urlString: self.urlString))
                
                switch response {
                case .success(let success):
                    self.uiImage = UIImage(data: success)
                case .failure:
                    self.uiImage = nil
                }
            } catch {
                self.uiImage = nil
            }
        }
    }
}

#Preview {
    URLImageView(urlString: "")
}
