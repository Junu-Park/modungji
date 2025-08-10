//
//  DetailView.swift
//  Modungji
//
//  Created by 박준우 on 8/10/25.
//

import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    
    init(viewModel: DetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Text("TEST")
    }
}
