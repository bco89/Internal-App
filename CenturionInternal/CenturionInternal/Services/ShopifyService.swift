import Foundation

class ShopifyService {
    private let shopifyDomain = "boardcoboats.myshopify.com"
    private let accessToken = "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"
    
    func fetchProducts(from collectionId: String) async throws -> [ShopifyBoat] {
        let query = """
        {
          collection(id: "gid://shopify/Collection/\(collectionId)") {
            products(first: 50) {
              edges {
                node {
                  id
                  title
                  descriptionHtml
                  priceRangeV2 {
                    minVariantPrice {
                      amount
                      currencyCode
                    }
                  }
                  images(first: 10) {
                    edges {
                      node {
                        url
                      }
                    }
                  }
                  status
                  tags
                  metafields(first: 20) {
                    edges {
                      node {
                        key
                        value
                        namespace
                        type
                        reference {
                          ... on GenericFile {
                            url
                            originalFileSize
                            mimeType
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        """
        
        let url = URL(string: "https://\(shopifyDomain)/admin/api/2024-01/graphql.json")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accessToken, forHTTPHeaderField: "X-Shopify-Access-Token")
        
        let queryBody = ["query": query]
        request.httpBody = try JSONSerialization.data(withJSONObject: queryBody)
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        
        #if DEBUG
        if let httpResponse = urlResponse as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            print("Response Headers:")
            httpResponse.allHeaderFields.forEach { key, value in
                print("\(key): \(value)")
            }
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw API Response:")
            print(jsonString)
        }
        #endif
        
        let shopifyResponse = try JSONDecoder().decode(ShopifyResponse.self, from: data)
        
        if let errors = shopifyResponse.errors, !errors.isEmpty {
            let errorMessage = errors[0].message.isEmpty ? 
                "Unauthorized access. Please check API credentials." : 
                errors[0].message
            
            throw NSError(
                domain: "ShopifyAPI",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey: errorMessage,
                    "DebugDescription": "Full response: \(String(describing: shopifyResponse))"
                ]
            )
        }
        
        guard let productData = shopifyResponse.data?.collection?.products else {
            throw NSError(
                domain: "ShopifyAPI",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "No product data received from Shopify"]
            )
        }
        
        return productData.edges.map { edge in
            // Get all image URLs except the first one (which is the main image)
            let additionalImages = Array(edge.node.images.edges.dropFirst().map { $0.node.url })
            
            // Convert metafields to options dictionary
            let options = edge.node.metafields?.edges.reduce(into: [String: String]()) { dict, edge in
                dict[edge.node.key] = edge.node.value
            } ?? [:]
            
            // Get build sheet URL
            let buildSheetUrl = edge.node.metafields?.edges
                .first { metafield in
                    metafield.node.key == "build_sheet" && 
                    metafield.node.type == "file_reference"
                }?
                .node.reference?.url
            
            print("Direct build sheet URL:", buildSheetUrl ?? "nil")
            
            // Get boat price from metafields
            let price: Double = {
                if let priceString = edge.node.metafields?.edges
                    .first(where: { $0.node.key == "boat_price" })?
                    .node.value
                    .replacingOccurrences(of: "[\"", with: "")
                    .replacingOccurrences(of: "\"]", with: ""),
                   let price = Double(priceString) {
                    return price
                }
                return Double(edge.node.priceRangeV2.minVariantPrice.amount) ?? 0
            }()
            
            let bottomLinePrice = edge.node.metafields?.edges.first { edge in 
                edge.node.key == "bottom_line" && edge.node.namespace == "custom"
            }.map { Double($0.node.value) } ?? nil
            
            return ShopifyBoat(
                id: UUID(),
                title: edge.node.title,
                description: edge.node.descriptionHtml,
                price: price,
                bottomLinePrice: bottomLinePrice,
                imageURL: URL(string: edge.node.images.edges.first?.node.url ?? ""),
                additionalImages: edge.node.images.edges.dropFirst().compactMap { 
                    URL(string: $0.node.url) 
                },
                isAvailable: edge.node.status == "ACTIVE",
                tags: edge.node.tags,
                buildSheetURL: URL(string: buildSheetUrl ?? "")
            )
        }
    }
}

struct ShopifyResponse: Codable {
    let data: CollectionData?
    let errors: [ShopifyError]?
}

struct CollectionData: Codable {
    let collection: CollectionProducts?
}

struct CollectionProducts: Codable {
    let products: ProductConnection
}

struct ShopifyError: Codable {
    let message: String
    let locations: [ErrorLocation]?
    let path: [String]?
}

struct ErrorLocation: Codable {
    let line: Int
    let column: Int
}

struct ProductConnection: Codable {
    let edges: [ProductEdge]
}

struct ProductEdge: Codable {
    let node: Product
}

struct Product: Codable {
    let id: String
    let title: String
    let descriptionHtml: String
    let priceRangeV2: PriceRange
    let images: ImageConnection
    let status: String
    let tags: [String]
    let metafields: MetafieldConnection?
}

struct PriceRange: Codable {
    let minVariantPrice: Money
}

struct Money: Codable {
    let amount: String
    let currencyCode: String
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

struct MetafieldConnection: Codable {
    let edges: [MetafieldEdge]
}

struct MetafieldEdge: Codable {
    let node: Metafield
}

struct Metafield: Codable {
    let key: String
    let value: String
    let namespace: String
    let type: String?
    let reference: GenericFile?
    
    struct GenericFile: Codable {
        let url: String
        let originalFileSize: Int
        let mimeType: String
    }
} 