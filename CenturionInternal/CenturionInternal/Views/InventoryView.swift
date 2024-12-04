import SwiftUI

enum InventoryType {
    case regular
    case boatShow
    
    var title: String {
        switch self {
        case .regular: return "Inventory"
        case .boatShow: return "Boat Show"
        }
    }
    
    var collectionId: String {
        switch self {
        case .regular: return "294208503946"
        case .boatShow: return "317830725770"
        }
    }
}

struct InventoryView: View {
    @State private var boats: [ShopifyBoat] = []
    @State private var isLoading = true
    @State private var error: Error?
    @State private var selectedBoat: ShopifyBoat?
    @State private var selectedInventoryType: InventoryType = .regular
    
    private let shopifyService = ShopifyService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Inventory Type Picker
                Picker("Inventory Type", selection: $selectedInventoryType) {
                    Text("Inventory").tag(InventoryType.regular)
                    Text("Boat Show").tag(InventoryType.boatShow)
                }
                .pickerStyle(.segmented)
                .padding()
                
                ZStack {
                    Theme.background.ignoresSafeArea()
                    
                    if isLoading {
                        ProgressView()
                            .tint(Theme.accent)
                    } else if let error = error {
                        errorView
                    } else {
                        boatList
                    }
                }
            }
            .navigationTitle(selectedInventoryType.title)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onChange(of: selectedInventoryType) { _ in
            Task {
                await loadBoats()
            }
        }
        .task {
            await loadBoats()
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Text("Error loading inventory")
                .font(.headline)
                .foregroundColor(Theme.text)
                .shadow(color: Theme.Shadows.text.color,
                       radius: Theme.Shadows.text.radius,
                       x: Theme.Shadows.text.x,
                       y: Theme.Shadows.text.y)
            
            Button("Retry") {
                Task { await loadBoats() }
            }
            .foregroundColor(Theme.background)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Theme.button())
        }
    }
    
    private var boatList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(boats) { boat in
                    InventoryBoatCard(boat: boat)
                        .shadow(color: Theme.Shadows.card.color,
                               radius: Theme.Shadows.card.radius,
                               x: Theme.Shadows.card.x,
                               y: Theme.Shadows.card.y)
                        .onTapGesture {
                            selectedBoat = boat
                        }
                }
            }
            .padding()
        }
        .background(Theme.background)
    }
    
    private func loadBoats() async {
        isLoading = true
        do {
            boats = try await shopifyService.fetchProducts(from: selectedInventoryType.collectionId)
        } catch {
            self.error = error
        }
        isLoading = false
    }
}

struct InventoryBoatCard: View {
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
            
            HStack(spacing: 16) {
                NavigationLink("Price Sheet") {
                    BoatPriceView(boat: boat)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
                
                Button(action: { showingOptions = true }) {
                    Text("Gallery & Options")
                }
                .buttonStyle(.bordered)
                .foregroundColor(Theme.accent)
            }
            .padding(.top, 8)
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