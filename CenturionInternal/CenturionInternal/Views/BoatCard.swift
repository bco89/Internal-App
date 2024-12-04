import SwiftUI

struct BoatCard: View {
    let boat: ShopifyBoat
    @State private var showingOptions = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if let imageURL = boat.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Text(boat.title)
                .font(.headline)
                .foregroundColor(Theme.text)
            
            HStack {
                Text("Starting at")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                
                Text(boat.price, format: .currency(code: "USD"))
                    .font(.title3)
                    .foregroundColor(Theme.accent)
            }
            
            Button(action: { showingOptions = true }) {
                HStack {
                    Text("Gallery & Options")
                        .font(.subheadline)
                        .foregroundColor(Theme.accent)
                    Spacer()
                    Text("→")
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Theme.Shadows.card.color,
                radius: Theme.Shadows.card.radius,
                x: Theme.Shadows.card.x,
                y: Theme.Shadows.card.y)
        .sheet(isPresented: $showingOptions) {
            BoatOptionsView(boat: boat)
        }
    }
} 