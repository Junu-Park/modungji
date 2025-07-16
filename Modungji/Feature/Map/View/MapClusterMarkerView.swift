//
//  MapClusterMarkerView.swift
//  Modungji
//
//  Created by 박준우 on 7/16/25.
//

import SwiftUI

struct MapClusterMarkerView: View {
    let count: Int
    
    private var circleSize: CGFloat {
        switch self.count {
        case ...20:
            return 50
        case 21...40:
            return 60
        case 41...60:
            return 70
        case 61...80:
            return 80
        case 81...100:
            return 90
        case 101...:
            return 100
        default:
            return 0
        }
    }
    
    var body: some View {
        Circle()
            .frame(width: self.circleSize, height: self.circleSize)
            .foregroundStyle(.deepCream.opacity(0.9))
            .overlay {
                Text("\(self.count)")
                    .foregroundStyle(.gray0)
                    .font(PDFont.title1.bold())
            }
    }
}

extension MapClusterMarkerView {
    func converToUIImage() -> UIImage {
        let render = ImageRenderer(content: self)
        render.scale = UIScreen.main.scale
        return render.uiImage ?? UIImage()
    }
}
