import SwiftUI

struct QuickSpecsView: View {
    let boats = [
        BoatSpecs(
            model: "Fe22",
            length: "22'",
            seatingCapacity: "13",
            fuelCapacity: "70 gal",
            weight: "6,700 lbs",
            ballast: "Up to 5,150 lbs",
            totalLength: "24'3\"",
            towerHeight: "8'5\"",
            buildSheetURL: URL(string: "https://cdn.shopify.com/s/files/1/0583/1111/4890/files/fe22-build-sheet.pdf")
        ),
        BoatSpecs(
            model: "Fe23",
            length: "23'",
            seatingCapacity: "14",
            fuelCapacity: "89 gal",
            weight: "6,900 lbs",
            ballast: "5,250 lbs",
            totalLength: "24'7\"",
            towerHeight: "8'4\"",
            buildSheetURL: URL(string: "https://cdn.shopify.com/s/files/1/0583/1111/4890/files/fe23-build-sheet.pdf")
        ),
        BoatSpecs(
            model: "Fe25",
            length: "25'",
            seatingCapacity: "16",
            fuelCapacity: "92 gal",
            weight: "7,200 lbs",
            ballast: "5,600 lbs",
            totalLength: "26'7\"",
            towerHeight: "8'4\"",
            buildSheetURL: URL(string: "https://cdn.shopify.com/s/files/1/0583/1111/4890/files/fe25-build-sheet.pdf")
        ),
        BoatSpecs(
            model: "Ri230",
            length: "23'",
            seatingCapacity: "14",
            fuelCapacity: "81 gal",
            weight: "7,000 lbs",
            ballast: "5,400 lbs",
            totalLength: "24'1.5\"",
            towerHeight: "Drop Zone 9'4\"",
            buildSheetURL: URL(string: "https://cdn.shopify.com/s/files/1/0583/1111/4890/files/ri230-build-sheet.pdf")
        ),
        BoatSpecs(
            model: "Ri245",
            length: "24'6\"",
            seatingCapacity: "16",
            fuelCapacity: "89 gal",
            weight: "7,300 lbs",
            ballast: "5,650 lbs",
            totalLength: "28'1\"",
            towerHeight: "Drop Zone 9'8.5\"",
            buildSheetURL: URL(string: "https://cdn.shopify.com/s/files/1/0583/1111/4890/files/ri245-build-sheet.pdf")
        ),
        BoatSpecs(
            model: "Ri265",
            length: "26'6\"",
            seatingCapacity: "Yacht Certified",
            fuelCapacity: "92 gal",
            weight: "8,000 lbs",
            ballast: "5,850 lbs",
            totalLength: "28'7\"",
            towerHeight: "Drop Zone 10'8\"",
            buildSheetURL: URL(string: "https://cdn.shopify.com/s/files/1/0583/1111/4890/files/ri265-build-sheet.pdf")
        ),
        BoatSpecs(
            model: "S220",
            length: "22'",
            seatingCapacity: "14",
            fuelCapacity: "70 gal",
            weight: "6,700 lbs",
            ballast: "4,400 lbs",
            totalLength: "24'10\"",
            towerHeight: "8'5\"",
            buildSheetURL: URL(string: "https://cdn.shopify.com/s/files/1/0583/1111/4890/files/s220-build-sheet.pdf")
        ),
        BoatSpecs(
            model: "S240",
            length: "24'",
            seatingCapacity: "16",
            fuelCapacity: "70 gal",
            weight: "7,100 lbs",
            ballast: "4,800 lbs",
            totalLength: "26'10\"",
            towerHeight: "8'5\"",
            buildSheetURL: URL(string: "https://cdn.shopify.com/s/files/1/0583/1111/4890/files/s240-build-sheet.pdf")
        )
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(boats) { boat in
                    SpecsBoatCard(boat: boat)
                }
            }
            .padding()
        }
        .navigationTitle("Quick Specs")
    }
}

struct SpecsBoatCard: View {
    let boat: BoatSpecs
    @State private var isExpanded = false
    @State private var showingBuildSheet = false
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: { withAnimation { isExpanded.toggle() }}) {
                HStack {
                    Text(boat.model)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.text)
                    
                    Spacer()
                    
                    Circle()
                        .fill(Theme.accent)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text(isExpanded ? "−" : "+")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
            
            if isExpanded {
                VStack(spacing: 12) {
                    SpecRow(title: "Length", value: boat.length)
                    SpecRow(title: "Total Length", value: boat.totalLength)
                    SpecRow(title: "Seating", value: boat.seatingCapacity)
                    SpecRow(title: "Weight", value: boat.weight)
                    SpecRow(title: "Fuel Capacity", value: boat.fuelCapacity)
                    SpecRow(title: "Ballast", value: boat.ballast)
                    SpecRow(title: "Tower Height", value: boat.towerHeight)
                    
                    if let buildSheetURL = boat.buildSheetURL {
                        Button(action: { showingBuildSheet = true }) {
                            HStack {
                                Text("View Build Sheet")
                                    .foregroundColor(Theme.accent)
                                Spacer()
                                Text("📄")
                            }
                            .padding(.top, 8)
                        }
                        .sheet(isPresented: $showingBuildSheet) {
                            PDFViewer(pdfURL: buildSheetURL)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Theme.Shadows.card.color,
                radius: Theme.Shadows.card.radius,
                x: Theme.Shadows.card.x,
                y: Theme.Shadows.card.y)
    }
}

struct SpecRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(Theme.textSecondary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(Theme.text)
        }
        .font(.subheadline)
    }
} 