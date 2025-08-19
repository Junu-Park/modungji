//
//  ImageCarouselView.swift
//  Modungji
//
//  Created by 박준우 on 8/12/25.
//

import SwiftUI

struct ImageCarouselView: View {
    @State private var currentIndex: Int = 0
    
    private let imageURLs: [String]
    
    init(imageURLs: [String]) {
        self.imageURLs = imageURLs
    }
    
    var body: some View {
        TabView(selection: self.$currentIndex) {
            ForEach(0..<imageURLs.count, id: \.self) { index in
                URLImageView(urlString: imageURLs[index]) {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(.brightCream)
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page)
        .overlay(alignment: .bottomTrailing) {
            Text("\(currentIndex + 1) / \(imageURLs.count)")
                .font(PDFont.caption2)
                .foregroundStyle(.gray0)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .shapeBorderBackground(shape: .capsule, backgroundColor: .gray75.opacity(0.5), borderColor: .gray75.opacity(0.75))
                .padding(.trailing, 20)
                .padding(.bottom, 16)
        }
    }
}
