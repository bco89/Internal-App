import Foundation

struct ShopifyBoat: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let price: Double
    let bottomLinePrice: Double?
    let imageURL: URL?
    let additionalImages: [URL]
    let isAvailable: Bool
    let tags: [String]
    
    var buildSheetURL: URL? {
        URL(string: "https://cdn.shopify.com/s/files/1/0583/1111/4890/files/\(title.lowercased().replacingOccurrences(of: " ", with: "-"))-build-sheet.pdf")
    }
    
    // Basic initializer
    init(id: UUID = UUID(), 
         title: String, 
         description: String, 
         price: Double, 
         bottomLinePrice: Double? = nil,
         imageURL: URL?,
         additionalImages: [URL] = [],
         isAvailable: Bool = true,
         tags: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.bottomLinePrice = bottomLinePrice
        self.imageURL = imageURL
        self.additionalImages = additionalImages
        self.isAvailable = isAvailable
        self.tags = tags
    }
    
    // Shopify initializer
    init(from product: ShopifyProduct) {
        self.init(
            title: product.title,
            description: product.description,
            price: product.priceRange.minVariantPrice.amount,
            imageURL: URL(string: product.images.edges.first?.node.url ?? ""),
            additionalImages: product.images.edges.dropFirst().compactMap { URL(string: $0.node.url) },
            isAvailable: product.status == "ACTIVE",
            tags: product.tags
        )
    }
} 