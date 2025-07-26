//
//  DefaultMapLeafMakerView.swift
//  Modungji
//
//  Created by 박준우 on 7/29/25.
//

import SwiftUI

struct DefaultMapLeafMakerView: ClusterMarkerViewProtocol {
    var body: some View {
        Image(.mapBubble)
            .resizable()
            .scaledToFill()
            .padding(.top, 6)
            .padding(.horizontal, -12)
            .frame(width: 72, height: 100)
    }
}
