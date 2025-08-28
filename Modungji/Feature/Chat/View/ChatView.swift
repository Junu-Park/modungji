//
//  ChatView.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import PhotosUI
import SwiftUI

struct ChatView: View {
    @ObservedObject private var viewModel: ChatViewModel
    
    @State private var keyboardHeight: CGFloat = 0
    @State private var isScrollBottom: Bool = false
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        Spacer(minLength: keyboardHeight == 0 ? 0.1 : keyboardHeight)
                            .id("Top")

                        ForEach(Array(self.viewModel.state.chatDataList.enumerated()), id: \.element.chatID) { index, chat in
                            VStack(spacing: 8) {
                                if isShowDateSeparator(chat: chat, index: index) {
                                    DateSeparator(date: chat.createdAt)
                                }
                                
                                ChatRow(
                                    chat: chat,
                                    isOpponentUser: chat.sender.userID == self.viewModel.state.chatRoomData.opponentUserData.userID
                                )
                            }
                            .id(chat.chatID)
                            .padding(.bottom, 8)
                        }
                        
                        Color.clear
                            .frame(height: 0.1)
                            .onAppear {
                                self.isScrollBottom = true
                            }
                            .onDisappear {
                                self.isScrollBottom = false
                            }
                            .id("Bottom")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .id("LazyVStack")
                }
                .customOnChange(value: self.viewModel.state.didInitData) { _ in
                    self.scrollToBottom(proxy: proxy, isInit: true)
                }
                .customOnChange(value: self.viewModel.state.chatDataList) { _ in
                    if self.isScrollBottom && self.viewModel.state.didInitData {
                        self.scrollToBottom(proxy: proxy)
                    }
                }
            }
            .onTapGesture {
                self.hideKeyboard()
            }
            
            ChatMessageInputView(viewModel: self.viewModel)
        }
        .navigationTitle(self.viewModel.state.chatRoomData.opponentUserData.nick)
        .onDisappear {
            self.viewModel.action(.disconnectSocket)
        }
        .alert(self.viewModel.state.errorMessage, isPresented: self.$viewModel.state.showErrorAlert) {
            Button("닫기") { }
        }
        .offset(y: -self.keyboardHeight)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.easeInOut(duration: 0.3), value: self.keyboardHeight)
        .onKeyboardNotification { height in
            var safeAreaBottom: CGFloat = 0
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first {
                safeAreaBottom = window.safeAreaInsets.bottom
            }
            
            self.keyboardHeight = height - safeAreaBottom
        } hideCallback: {
            self.keyboardHeight = 0
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, isInit: Bool = false) {
        if isInit {
            DispatchQueue.main.async {
                proxy.scrollTo("LazyVStack", anchor: .bottom)
            }
        } else {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo("LazyVStack", anchor: .bottom)
            }
        }
    }
    
    private func isShowDateSeparator(chat: ChatResponseEntity, index: Int) -> Bool {
        if index == 0 {
            return true
        } else {
            let preChatDate = Calendar.current.startOfDay(for: self.viewModel.state.chatDataList[index - 1].createdAt)
            let curChatDate = Calendar.current.startOfDay(for: chat.createdAt)
            
            return preChatDate != curChatDate
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - 날짜 구분선
private struct DateSeparator: View {
    let date: Date
    
    var formattedDateString: String {
        let formatter = DateFormatter()
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self.date) {
            return "오늘"
        } else if calendar.isDateInYesterday(self.date) {
            return "어제"
        } else if calendar.isDate(self.date, equalTo: .now, toGranularity: .year){
            formatter.dateFormat = "MM월 dd일 EEEE"
        } else {
            formatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
        }
        
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self.date)
    }
    
    var body: some View {
        Text(self.formattedDateString)
            .font(PDFont.caption2)
            .foregroundColor(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .shapeBorderBackground(shape: .capsule, backgroundColor: .clear, borderColor: .gray60, borderWidth: 0.5)
            .padding(.vertical, 8)
    }
}

// MARK: - 채팅 Row
private struct ChatRow: View {
    let chat: ChatResponseEntity
    let isOpponentUser: Bool
    
    var formattedTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: self.chat.createdAt)
    }
    
    var body: some View {
        HStack {
            if isOpponentUser {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        URLImageView(urlString: chat.sender.profileImage) {
                            Circle()
                                .fill(.gray45)
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chat.sender.nick)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            messageContent
                            
                            Text(self.formattedTimeString)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
            } else {
                Spacer(minLength: 100)
                
                VStack(alignment: .trailing, spacing: 4) {
                    messageContent
                    
                    Text(self.formattedTimeString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var messageContent: some View {
        VStack(alignment: isOpponentUser ? .leading : .trailing, spacing: 8) {
            // 텍스트 메시지
            Text(chat.content)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isOpponentUser ? .gray30 : .deepCoast)
                )
                .foregroundColor(isOpponentUser ? .gray100 : .gray0)
            
            // 파일 첨부
            if !chat.files.isEmpty {
                ForEach(chat.files, id: \.self) { fileName in
                    FileAttachmentView(fileName: fileName)
                }
            }
        }
    }
}

struct FileAttachmentView: View {
    let fileName: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: fileIcon)
                .foregroundColor(.blue)
            
            Text(fileName)
                .font(.caption)
                .lineLimit(1)
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "arrow.down.circle")
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
        .frame(maxWidth: 200)
    }
    
    private var fileIcon: String {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        switch fileExtension {
        case "jpg", "jpeg", "png", "gif":
            return "photo"
        case "pdf":
            return "doc.text"
        case "mp4", "mov":
            return "video"
        case "mp3", "wav":
            return "music.note"
        default:
            return "doc"
        }
    }
}

// MARK: - 채팅 입력 뷰
private struct ChatMessageInputView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                PhotosPicker(selection: self.$viewModel.state.selectedPhotos, maxSelectionCount: 5) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                TextField("메시지 입력", text: self.$viewModel.state.content, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...5)
                
                Button {
                    self.viewModel.action(.sendChat)
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(self.viewModel.state.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
                .disabled(self.viewModel.state.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.gray0)
    }
}
