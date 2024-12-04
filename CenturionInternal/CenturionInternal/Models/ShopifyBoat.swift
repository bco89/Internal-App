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
    let buildSheetURL: URL?
    
    init(id: UUID = UUID(),
         title: String,
         description: String,
         price: Double,
         bottomLinePrice: Double? = nil,
         imageURL: URL?,
         additionalImages: [URL] = [],
         isAvailable: Bool = true,
         tags: [String] = [],
         buildSheetURL: URL? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.bottomLinePrice = bottomLinePrice
        self.imageURL = imageURL
        self.additionalImages = additionalImages
        self.isAvailable = isAvailable
        self.tags = tags
        self.buildSheetURL = buildSheetURL
    }
}