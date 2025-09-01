//
//  PDFView.swift
//  Modungji
//
//  Created by 박준우 on 9/1/25.
//

import SwiftUI
import PDFKit

struct PDFView: View {
    let url: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var pdfDocument: PDFDocument?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var currentPage: Int = 0
    @State private var totalPages: Int = 0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if let pdfDocument = pdfDocument {
                contentView(document: pdfDocument)
            } else {
                errorView(message: "PDF를 로드할 수 없습니다")
            }
        }
        .statusBarHidden()
        .onAppear {
            loadPDF()
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.5)
            
            Text("PDF를 로드하는 중...")
                .foregroundColor(.white)
                .font(.body)
        }
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.white)
            
            Text(message)
                .foregroundColor(.white)
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button("닫기") {
                dismiss()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white, lineWidth: 1)
            )
        }
        .padding()
    }
    
    // MARK: - Content View
    private func contentView(document: PDFDocument) -> some View {
        ZStack {
            PDFViewRepresentable(
                document: document,
                currentPage: $currentPage,
                totalPages: $totalPages
            )
            
            headerView
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
                
                if totalPages > 1 {
                    Text("\(currentPage + 1) / \(totalPages)")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
                
                Button {
                    sharePDF()
                } label: {
                    Image(systemName: "arrow.down.circle")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                }
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
    
    // MARK: - Load PDF
    private func loadPDF() {
        Task {
            do {
                let response = try await NetworkManager().requestEstate(requestURL: EstateRouter.File.file(urlString: url))
                
                await MainActor.run {
                    switch response {
                    case .success(let data):
                        if let document = PDFDocument(data: data) {
                            self.pdfDocument = document
                            self.totalPages = document.pageCount
                            self.isLoading = false
                        } else {
                            self.errorMessage = "PDF 파일을 읽을 수 없습니다"
                            self.isLoading = false
                        }
                    case .failure(let error):
                        self.errorMessage = "네트워크 오류: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "PDF 로드 중 오류가 발생했습니다"
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Save PDF to Files App
    private func sharePDF() {
        guard let pdfDocument = pdfDocument,
              let data = pdfDocument.dataRepresentation() else {
            return
        }
        
        // PDF 파일명 생성 (URL에서 파일명 추출하거나 기본값 사용)
        let fileName = extractFileName(from: url) ?? "document.pdf"
        
        let documentPicker = UIDocumentPickerViewController(forExporting: [createTemporaryFile(data: data, fileName: fileName)])
        documentPicker.modalPresentationStyle = .formSheet
        
        // 약간의 딜레이를 주어 present 충돌 방지
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.findTopViewController()?.present(documentPicker, animated: true)
        }
    }
    
    // MARK: - Find Top View Controller
    private func findTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        var topController = window.rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
    
    // MARK: - Helper Methods
    private func createTemporaryFile(data: Data, fileName: String) -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
        } catch {
            print("임시 파일 생성 중 오류 발생: \(error)")
        }
        
        return tempURL
    }
    
    private func extractFileName(from urlString: String) -> String? {
        guard let url = URL(string: urlString),
              let fileName = url.pathComponents.last,
              !fileName.isEmpty else {
            return nil
        }
        
        // 파일 확장자가 없으면 .pdf 추가
        if !fileName.contains(".") {
            return "\(fileName).pdf"
        }
        
        return fileName
    }
}

// MARK: - PDFViewRepresentable
struct PDFViewRepresentable: UIViewRepresentable {
    let document: PDFDocument
    @Binding var currentPage: Int
    @Binding var totalPages: Int
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .black
        
        // 페이지 변경 알림 등록
        NotificationCenter.default.addObserver(
            forName: .PDFViewPageChanged,
            object: pdfView,
            queue: .main
        ) { _ in
            if let currentPDFPage = pdfView.currentPage {
                let pageIndex = document.index(for: currentPDFPage)
                currentPage = pageIndex
            }
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document != document {
            uiView.document = document
            totalPages = document.pageCount
        }
    }
}
