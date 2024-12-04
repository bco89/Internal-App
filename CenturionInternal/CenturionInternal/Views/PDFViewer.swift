import SwiftUI
import PDFKit
import QuickLook

struct PDFViewer: View {
    let pdfURL: URL
    @Environment(\.dismiss) private var dismiss
    @State private var document: PDFDocument?
    @State private var loadError: Error?
    @State private var previewURL: URL?
    
    var body: some View {
        NavigationView {
            Group {
                if let document = document {
                    PDFKitView(document: document)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    previewURL = pdfURL
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                            }
                        }
                } else if let error = loadError {
                    VStack(spacing: 16) {
                        Text("Error loading PDF")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Button("Retry") {
                            loadPDF()
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Build Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            loadPDF()
        }
        .quickLookPreview($previewURL)
    }
    
    private func loadPDF() {
        print("Attempting to load PDF from URL:", pdfURL.absoluteString)
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: pdfURL)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code:", httpResponse.statusCode)
                    print("Response Headers:", httpResponse.allHeaderFields)
                }
                
                print("Successfully downloaded data, size:", data.count)
                
                // Try to determine content type
                if let contentType = (response as? HTTPURLResponse)?.allHeaderFields["Content-Type"] as? String {
                    print("Content-Type:", contentType)
                }
                
                // Save PDF data to temporary file
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pdf")
                try data.write(to: tempURL)
                
                if let document = PDFDocument(url: tempURL) {
                    print("Successfully created PDF from data")
                    await MainActor.run {
                        self.document = document
                    }
                } else {
                    print("Failed to create PDF from data")
                    // Print first few bytes to help debug
                    let previewData = String(data: data.prefix(100), encoding: .utf8) ?? "Not text data"
                    print("First 100 bytes:", previewData)
                    throw NSError(domain: "PDFViewer", 
                                code: -1, 
                                userInfo: [NSLocalizedDescriptionKey: "Invalid PDF format"])
                }
            } catch {
                print("Error downloading PDF:", error)
                await MainActor.run {
                    self.loadError = error
                }
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
} 