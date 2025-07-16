//
//  MapBubbleMarkerView.swift
//  Modungji
//
//  Created by 박준우 on 7/16/25.
//

import SwiftUI

struct MapBubbleMarkerView: View {
    let imageName: String
    let depositPay: Int
    let monthPay: Int
    
    var body: some View {
        Image(.mapBubble)
            .padding(.top, 6)
            .frame(width: 72, height: 100)
            .overlay(alignment: .top) {
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 64, height: 64)
                        .foregroundStyle(.brightCoast)
                    
                    Text("\(self.depositPay)/\(monthPay)")
                        .font(PDFont.caption2.bold())
                        .foregroundStyle(.gray60)
                }
                .padding(.top, 4)
            }
    }
}

extension MapBubbleMarkerView {
    func converToUIImage() -> UIImage {
        let render = ImageRenderer(content: self)
        render.scale = UIScreen.main.scale
        return render.uiImage ?? UIImage()
    }
}

#Preview {
    MapBubbleMarkerView(imageName: "Test", depositPay: 1000, monthPay: 40)
}
