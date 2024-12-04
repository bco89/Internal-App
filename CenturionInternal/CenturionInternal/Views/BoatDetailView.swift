import SwiftUI

struct BoatDetailView: View {
    let boat: ShopifyBoat
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let imageURL = boat.imageURL {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                        }
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Text(boat.description)
                        .font(.body)
                        .foregroundColor(Theme.text)
                    
                    // ... rest of the view implementation
                }
                .padding()
            }
            .navigationTitle(boat.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    BoatDetailView(boat: ShopifyBoat(
        id: UUID(),
        title: "Sample Boat",
        description: "This is a sample boat description",
        price: 189999.99,
        bottomLinePrice: nil,
        imageURL: URL(string: "https://example.com/boat.jpg"),
        additionalImages: [],
        isAvailable: true,
        tags: ["Sample", "Preview"]
    ))
} 