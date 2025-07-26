//
//  MapLeafMarkerView.swift
//  Modungji
//
//  Created by 박준우 on 7/16/25.
//

import SwiftUI

struct MapLeafMarkerView: ClusterMarkerViewProtocol {
    let image: UIImage
    let deposit: Int
    let monthlyRent: Int
    
    var body: some View {
        Image(.mapBubble)
            .resizable()
            .scaledToFill()
            .padding(.top, 6)
            .padding(.horizontal, -12)
            .frame(width: 72, height: 100)
            .overlay(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    Text("\(self.convertPriceToString(deposit)) / \(self.convertPriceToString(monthlyRent))")
                        .font(PDFont.caption2.bold())
                        .foregroundStyle(.gray60)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding([.top, .horizontal], 4)
            }
    }
    
    private func convertPriceToString(_ price: Int) -> String {
        if price >= 1000000000000 {
            return String(price / 1000000000000) + "조"
        }
        else if price >= 100000000 {
            return String(price / 100000000) + "억"
        } else if price >= 10000 {
            return String(price / 10000) + "만"
        } else {
            return "1만↓"
        }
    }
}
