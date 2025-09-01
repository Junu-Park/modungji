//
//  ZoomInImageView.swift
//  Modungji
//
//  Created by Claude on 8/31/25.
//

import SwiftUI

struct ZoomInImageView: View {
    private let imageURLs: [String]
    @Binding private var isPresented: Bool
    
    @State private var selectedIndex: Int = 0
    @State private var dismissOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    init(imageURLs: [String], selectedIndex: Int, isPresented: Binding<Bool>) {
        self.imageURLs = imageURLs
        self.selectedIndex = selectedIndex
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(isDragging ? 0.8 : 1.0)
            
            if imageURLs.isEmpty {
                emptyStateView
            } else {
                contentView
            }
        }
        .statusBarHidden()
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("이미지를 찾을 수 없습니다")
                .foregroundColor(.white)
                .font(.body)
            
            Button("닫기") {
                isPresented = false
            }
            .foregroundColor(.white)
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        ZStack {
            headerView
            imageContentView
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack {
            HStack {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
                
                if imageURLs.count > 1 {
                    Text("\(selectedIndex + 1) / \(imageURLs.count)")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
                
                Color.clear
                    .frame(width: 44, height: 44)
                    .padding()
            }
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.6), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            Spacer()
        }
        .zIndex(1)
    }
    
    // MARK: - Image Content View
    private var imageContentView: some View {
        Group {
            if imageURLs.count == 1 {
                ZoomableImageView(imageURL: imageURLs[0]) { isDragging in
                    self.isDragging = isDragging
                }
            } else {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, imageURL in
                        ZoomableImageView(imageURL: imageURL) { isDragging in
                            self.isDragging = isDragging
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .gesture(dismissGesture)
        .offset(y: dismissOffset.height)
    }
    
    // MARK: - Dismiss Gesture
    private var dismissGesture: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                // 세로 드래그가 가로 드래그보다 클 때만 닫기 제스처 활성화
                if abs(dragValue.translation.height) > abs(dragValue.translation.width) && 
                   abs(dragValue.translation.height) > 20 {
                    dismissOffset = dragValue.translation
                    isDragging = true
                }
            }
            .onEnded { dragValue in
                if abs(dragValue.translation.height) > 100 {
                    isPresented = false
                } else {
                    withAnimation(.spring()) {
                        dismissOffset = .zero
                        isDragging = false
                    }
                }
            }
    }
}

// MARK: - Zoomable Image View
struct ZoomableImageView: View {
    let imageURL: String
    let onDragChange: (Bool) -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            URLImageView(urlString: imageURL) {
                Rectangle()
                    .fill(.gray45)
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            }
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(zoomGesture)
            .simultaneousGesture(panGesture(geometry: geometry))
            .onTapGesture(count: 2, perform: handleDoubleTap)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .clipped()
    }
    
    // MARK: - Zoom Gesture
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                scale = max(1.0, min(newScale, 5.0))
            }
            .onEnded { _ in
                lastScale = scale
                if scale < 1.0 {
                    resetZoom()
                }
            }
    }
    
    // MARK: - Pan Gesture  
    private func panGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { dragValue in
                // 확대된 상태에서만 이미지 이동 처리
                if scale > 1.0 {
                    let newOffset = CGSize(
                        width: lastOffset.width + dragValue.translation.width,
                        height: lastOffset.height + dragValue.translation.height
                    )
                    
                    let maxOffsetX = (geometry.size.width * (scale - 1)) / 2
                    let maxOffsetY = (geometry.size.height * (scale - 1)) / 2
                    
                    offset = CGSize(
                        width: max(-maxOffsetX, min(maxOffsetX, newOffset.width)),
                        height: max(-maxOffsetY, min(maxOffsetY, newOffset.height))
                    )
                    
                    onDragChange(true)
                }
                // 확대되지 않은 상태에서는 아무것도 하지 않음 (상위 제스처가 처리)
            }
            .onEnded { _ in
                if scale > 1.0 {
                    lastOffset = offset
                    onDragChange(false)
                } else {
                    onDragChange(false)
                }
            }
    }
    
    // MARK: - Double Tap Handler
    private func handleDoubleTap() {
        withAnimation(.spring()) {
            if scale > 1.0 {
                resetZoom()
            } else {
                scale = 2.0
                lastScale = 2.0
            }
        }
    }
    
    // MARK: - Reset Zoom
    private func resetZoom() {
        withAnimation(.spring()) {
            scale = 1.0
            lastScale = 1.0
            offset = .zero
            lastOffset = .zero
        }
    }
}
