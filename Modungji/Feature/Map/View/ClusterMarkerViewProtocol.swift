//
//  ClusterMarkerViewProtocol.swift
//  Modungji
//
//  Created by 박준우 on 7/26/25.
//

import SwiftUI

@MainActor @preconcurrency
protocol ClusterMarkerViewProtocol: View { }

extension ClusterMarkerViewProtocol {
    func converToUIImage() -> UIImage {
        let render = ImageRenderer(content: self)
        render.scale = UIScreen.main.scale
        return render.uiImage ?? UIImage()
    }
}
