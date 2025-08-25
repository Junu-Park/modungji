//
//  ChatRoomListView.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import SwiftUI

import RealmSwift

struct ChatRoomListView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject private var viewModel: ChatRoomListViewModel
    
    init(viewModel: ChatRoomListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(self.viewModel.state.chatRoomList, id: \.roomID) { chatRoom in
            Button {
                self.viewModel.action(.tapChatRoom(opponentID: chatRoom.opponentUserData.userID, roomID: chatRoom.roomID))
            } label: {
                ChatRoomRow(chatRoom: chatRoom)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            self.viewModel.action(.fetchChatRoomList)
        }
        .refreshable {
            self.viewModel.action(.fetchChatRoomList)
        }
        .onChange(of: self.scenePhase) { value in
            if value == .active {
                self.viewModel.action(.fetchChatRoomList)
            }
        }
        .alert(self.viewModel.state.errorMessage, isPresented: self.$viewModel.state.showErrorAlert) {
            Button("닫기") { }
        }
    }
}

private struct ChatRoomRow: View {
    let chatRoom: ChatRoomResponseEntity
    
    private var relativeTimeString: String {
        let date = self.chatRoom.lastChat?.createdAt ?? chatRoom.updatedAt
        
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateTimeStyle = .named
        
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            URLImageView(urlString: self.chatRoom.opponentUserData.profileImage) {
                Circle()
                    .fill(.gray45)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
            }
            .frame(width: 50, height: 50)
            .clipShape(.circle)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(self.chatRoom.opponentUserData.nick)
                        .font(PDFont.body1)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(relativeTimeString)
                        .font(PDFont.caption1)
                        .foregroundColor(.secondary)
                }
                
                Group {
                    if let lastMessage = chatRoom.lastChat?.content {
                        Text(lastMessage)
                            .lineLimit(2)
                    } else {
                        Text("")
                    }
                }
                .font(PDFont.caption1)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
