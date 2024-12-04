import SwiftUI

// Add this helper function at the top of the file
private func formatDescription(_ htmlString: String) -> AttributedString {
    do {
        // Convert HTML to NSAttributedString
        guard let data = htmlString.data(using: .utf8) else {
            return AttributedString(htmlString)
        }
        
        let attributedString = try NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
        
        // Convert to AttributedString and apply styling
        var result = AttributedString(attributedString)
        result.foregroundColor = Theme.text.toUIColor()
        result.font = .body
        
        return result
    } catch {
        return AttributedString(htmlString)
    }
}

struct BoatOptionsView: View {
    let boat: ShopifyBoat
    @Environment(\.dismiss) private var dismiss
    @State private var showingBuildSheet = false
    @State private var selectedImageIndex = 0
    @State private var showingFullScreenImage = false
    
    var allImages: [URL] {
        var images: [URL] = []
        if let mainImage = boat.imageURL {
            images.append(mainImage)
        }
        images.append(contentsOf: boat.additionalImages)
        return images
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Gallery Section with paging
                    TabView(selection: $selectedImageIndex) {
                        ForEach(allImages.indices, id: \.self) { index in
                            AsyncImage(url: allImages[index]) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .onTapGesture {
                                        selectedImageIndex = index
                                        showingFullScreenImage = true
                                    }
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                            }
                            .tag(index)
                        }
                    }
                    .frame(height: 300)
                    .tabViewStyle(.page)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Build Sheet Button
                    if let buildSheetURL = boat.buildSheetURL {
                        Button(action: { 
                            print("Opening build sheet URL:", buildSheetURL.absoluteString)
                            showingBuildSheet = true 
                        }) {
                            HStack {
                                Text("View Build Sheet")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("📄")
                            }
                            .padding()
                            .background(Theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About This Model")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.text)
                        
                        Text(formatDescription(boat.description))
                            .foregroundColor(Theme.text)
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)  // Allow text selection
                    }
                    .padding()
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Tags Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Features")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(boat.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Theme.accent.opacity(0.2))
                                    .foregroundColor(Theme.accent)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding()
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle(boat.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingBuildSheet) {
                if let buildSheetURL = boat.buildSheetURL {
                    PDFViewer(pdfURL: buildSheetURL)
                }
            }
            .fullScreenCover(isPresented: $showingFullScreenImage) {
                ImageViewer(
                    images: allImages,
                    selectedIndex: $selectedImageIndex,
                    isPresented: $showingFullScreenImage
                )
            }
        }
    }
}

// Add this helper view for full-screen image viewing
struct ImageViewer: View {
    let images: [URL]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedIndex) {
                ForEach(images.indices, id: \.self) { index in
                    AsyncImage(url: images[index]) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(1.0)
                    } placeholder: {
                        ProgressView()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
} 