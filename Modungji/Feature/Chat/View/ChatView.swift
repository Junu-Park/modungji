//
//  ChatView.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject private var viewModel: ChatViewModel
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Text(self.viewModel.state.chatRoomData.roomID)
        }
    }
}
