import Foundation

struct ShopifyProduct: Codable {
    let title: String
    let description: String
    let status: String
    let tags: [String]
    let priceRange: PriceRange
    let images: ImageConnection
    
    struct PriceRange: Codable {
        let minVariantPrice: Money
    }
    
    struct Money: Codable {
        let amount: Double
    }
    
    struct ImageConnection: Codable {
        let edges: [ImageEdge]
    }
    
    struct ImageEdge: Codable {
        let node: Image
    }
    
    struct Image: Codable {
        let url: String
    }
} 