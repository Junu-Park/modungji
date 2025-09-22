//
//  ChatView.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import PDFKit
import PhotosUI
import SwiftUI

struct ChatView: View {
    @Namespace var topID
    @Namespace var bottomID
    
    @ObservedObject private var viewModel: ChatViewModel
    
    @State private var keyboardHeight: CGFloat = DeviceType.getDeviceType().keyboardHeight
    @State private var isScrollBottom: Bool = false
    @State private var showFileTypeSelector: Bool = false
    @State private var showFilePicker: Bool = false
    @State private var showPhotoPicker: Bool = false
    
    @FocusState private var showKeyboard: Bool
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        Spacer(minLength: self.showKeyboard || self.showFileTypeSelector ? keyboardHeight : 0.1)
                            .id(topID)

                        ForEach(Array(self.viewModel.state.chatDataList.enumerated()), id: \.element.chatID) { index, chat in
                            VStack(spacing: 8) {
                                if isShowDateSeparator(chat: chat, index: index) {
                                    DateSeparator(date: chat.createdAt)
                                }
                                
                                ChatRow(
                                    chat: chat,
                                    isOpponentUser: chat.sender.userID == self.viewModel.state.chatRoomData.opponentUserData.userID,
                                    showTime: checkShowTime(chat: chat, index: index),
                                    showProfile: checkShowProfile(chat: chat, index: index)
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
                            .id(bottomID)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .customOnChange(value: self.viewModel.state.chatDataList) { _ in
                    if !self.isScrollBottom { return }
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(self.bottomID, anchor: .bottom)
                    }
                }
            }
            .onTapGesture {
                self.hideKeyboard()
                self.showFileTypeSelector = false
            }
            
            self.buildChatInputView()
        }
        .overlay {
            if self.viewModel.state.showLoading {
                ProgressView()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .tint(.deepCoast)
                    .background(.gray45)
            }
        }
        .photosPicker(isPresented: self.$showPhotoPicker, selection: self.$viewModel.state.photoSelection, maxSelectionCount: 5)
        .fileImporter(isPresented: self.$showFilePicker, allowedContentTypes: [.jpeg, .png, .jpeg, .gif, .pdf], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls):
                self.viewModel.action(.appendFile(urls: urls))
            case .failure(let failure):
                print(failure)
            }
        }
        .overlay(alignment: .bottom) {
            if self.showFileTypeSelector {
                HStack(spacing: 32) {
                    Button {
                        self.showPhotoPicker.toggle()
                    } label: {
                        Text("사진")
                            .padding(16)
                            .background {
                                Circle()
                                    .stroke(Color.gray45, lineWidth: 1)
                            }
                    }
                    
                    Button {
                        self.showFilePicker.toggle()
                    } label: {
                        Text("파일")
                            .padding(16)
                            .background {
                                Circle()
                                    .stroke(Color.gray45, lineWidth: 1)
                            }
                    }
                }
                .frame(height: self.keyboardHeight)
                .offset(y: self.showKeyboard || self.showFileTypeSelector ? self.keyboardHeight : 0)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    self.viewModel.action(.tapBackButton)
                } label: {
                    Image(.chevron)
                        .renderingMode(.template)
                        .foregroundStyle(.gray100)
                }
            }
        }
        .navigationTitle(self.viewModel.state.chatRoomData.opponentUserData.nick)
        .onDisappear {
            self.viewModel.action(.disconnectSocket)
        }
        .alert(self.viewModel.state.errorMessage, isPresented: self.$viewModel.state.showErrorAlert) {
            Button("닫기") { }
        }
        .offset(y: self.showKeyboard || self.showFileTypeSelector ? -self.keyboardHeight : 0)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .customOnChange(value: self.showKeyboard) { value in
            if value {
                self.showFileTypeSelector = false
            }
        }
        .onKeyboardNotification { height in
            self.keyboardHeight = height - self.bottomSafeAreaPadding
        } hideCallback: { }
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

    private func checkShowTime(chat: ChatResponseEntity, index: Int) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let currentTimeString = formatter.string(from: chat.createdAt)

        if index == self.viewModel.state.chatDataList.count - 1 {
            return true
        }

        let nextChat = self.viewModel.state.chatDataList[index + 1]
        let nextTimeString = formatter.string(from: nextChat.createdAt)

        return currentTimeString != nextTimeString || chat.sender.userID != nextChat.sender.userID
    }

    private func checkShowProfile(chat: ChatResponseEntity, index: Int) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let currentTimeString = formatter.string(from: chat.createdAt)

        if index == 0 {
            return true
        }

        let previousChat = self.viewModel.state.chatDataList[index - 1]
        let previousTimeString = formatter.string(from: previousChat.createdAt)

        return currentTimeString != previousTimeString || chat.sender.userID != previousChat.sender.userID
    }
    
    @ViewBuilder
    private func buildChatInputView() -> some View {
        VStack(spacing: 0) {
            Divider()
            
            // 선택된 사진 썸네일 표시
            if !self.viewModel.state.selectedPhoto.isEmpty || !self.viewModel.state.fileSelection.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(self.viewModel.state.selectedPhoto.enumerated()), id: \.element) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Button {
                                    self.viewModel.action(.removePhoto(index: index))
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .background(Circle().fill(.black.opacity(0.6)))
                                }
                                .offset(x: -1, y: 1)
                            }
                        }
                        
                        ForEach(Array(self.viewModel.state.fileSelection.enumerated()), id: \.element) { index, file in
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "document")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Button {
                                    self.viewModel.action(.removeFile(index: index))
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .background(Circle().fill(.black.opacity(0.6)))
                                }
                                .offset(x: -1, y: 1)
                            }
                        }
                        
                        Button {
                            self.viewModel.action(.removePhoto(index: nil))
                            self.viewModel.action(.removeFile(index: nil))
                        } label: {
                            Image(systemName: "trash.circle")
                                .font(.title)
                                .foregroundStyle(.gray60)
                        }

                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 8)
            }
            
            HStack(spacing: 16){
                // 전송 파일 타입 선택
                Button {
                    withAnimation(nil) {
                        if showFileTypeSelector {
                            showFileTypeSelector = false
                            showKeyboard = true
                        } else {
                            showFileTypeSelector = true
                            showKeyboard = false
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                // 채팅 입력
                TextField("메시지 입력", text: self.$viewModel.state.content, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...5)
                    .focused(self.$showKeyboard)
                
                // 채팅 전송
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
    let showTime: Bool
    let showProfile: Bool
    
    @State private var showImageViewer: Bool = false
    @State private var selectedIndex: Int = 0
    @State private var showPDFViewer: Bool = false
    @State private var selectedPDF: String = ""
    
    private var photoURLs: [String] {
        
        return chat.files.filter { url in
            guard let pointIndex = url.lastIndex(of: ".") else {
                return false
            }
            
            let startIndex = url.index(after: pointIndex)
            
            if startIndex >= url.endIndex {
                return false
            }
            
            let extensionString = String(url[startIndex...]).lowercased()
            
            return ["jpeg", "jpg", "gif", "png"].contains(extensionString)
        }
    }
    
    private var fileURLs: [String] {
        
        return chat.files.filter { url in
            guard let pointIndex = url.lastIndex(of: ".") else {
                return false
            }
            
            let startIndex = url.index(after: pointIndex)
            
            if startIndex >= url.endIndex {
                return false
            }
            
            let extensionString = String(url[startIndex...])
            
            return "pdf" == extensionString
        }
    }
    
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
                        if showProfile {
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
                        } else {
                            Spacer()
                                .frame(width: 40, height: 40)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            if showProfile {
                                Text(chat.sender.nick)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            self.buildContentView()

                            if showTime {
                                Text(self.formattedTimeString)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
            } else {
                Spacer(minLength: 100)
                
                VStack(alignment: .trailing, spacing: 4) {
                    self.buildContentView()

                    if showTime {
                        Text(self.formattedTimeString)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func buildContentView() -> some View {
        let cols = Array(repeating: GridItem(.fixed(50), spacing: 8), count: chat.files.count < 3 ? chat.files.count : 3)
        
        VStack(alignment: isOpponentUser ? .leading : .trailing, spacing: 8) {
            // 채팅
            if !chat.content.isEmpty {
                Text(chat.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isOpponentUser ? .gray30 : .deepCoast)
                    )
                    .foregroundColor(isOpponentUser ? .gray100 : .gray0)
            }
            
            // 사진
            if !self.photoURLs.isEmpty {
                LazyVGrid(columns: cols, spacing: 8) {
                    ForEach(Array(self.photoURLs.enumerated()), id: \.element) { index, photoURL in
                        Button {
                            selectedIndex = index
                            showImageViewer.toggle()
                        } label: {
                            URLImageView(urlString: photoURL) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.gray45)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .foregroundColor(.white)
                                            .font(.system(size: 20))
                                    }
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .fixedSize()
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray30)
                )
                .fullScreenCover(isPresented: self.$showImageViewer) {
                    ZoomInImageView(
                        imageURLs: self.chat.files,
                        selectedIndex: self.selectedIndex,
                        isPresented: self.$showImageViewer
                    )
                }
            }
            
            // 파일
            if !self.fileURLs.isEmpty {
                ForEach(self.fileURLs, id: \.self) { fileURL in
                    Button {
                        self.selectedPDF = fileURL
                        self.showPDFViewer.toggle()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text.image")
                                .font(.title3)
                                .foregroundStyle(.gray60)
                                .padding(8)
                                .background(Circle().foregroundStyle(.white))
                            
                            HStack(spacing: 0) {
                                Text(self.extractFileName(url: fileURL))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                                Text(".\(self.extractFileExtension(url: fileURL))")
                                    .layoutPriority(1)
                            }
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.gray30)
                    )
                    .fullScreenCover(isPresented: self.$showPDFViewer) {
                        PDFPreviewView(url: fileURL)
                    }
                }
            }
        }
        // iOS 17.x 버전에서는 onChange 모디파이어 없으니 fullScreenCover 작동 안 함(시뮬, 실기기 동일)
        .onChange(of: showImageViewer) { _ in }
        .onChange(of: showPDFViewer) { _ in }
    }
    
    private func extractFileName(url: String) -> String {
        let fullName = String(url.split(separator: "/").last!)
        
        return String(fullName.split(separator: ".").first!)
    }
    
    private func extractFileExtension(url: String) -> String {
        return String(url.split(separator: ".").last!)
    }
}
