//
//  ContentView.swift
//  Modungji
//
//  Created by 박준우 on 5/9/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Group {
                KakaoLoginButtonView()
                
                AppleLoginButtonView()
            }
            .frame(height: 50)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ContentView()
}
