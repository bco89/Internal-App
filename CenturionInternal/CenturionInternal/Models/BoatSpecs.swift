import Foundation

struct BoatSpecs: Identifiable {
    let id = UUID()
    let model: String
    let length: String
    let seatingCapacity: String
    let fuelCapacity: String
    let weight: String
    let ballast: String
    let totalLength: String
    let towerHeight: String
    let buildSheetURL: URL?
} 