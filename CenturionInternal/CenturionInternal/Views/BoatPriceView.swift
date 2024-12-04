import SwiftUI

struct BoatPriceView: View {
    let boat: ShopifyBoat
    @State private var showingBottomLine = false
    @State private var boatPrice: Double
    @State private var downPayment: Double
    @State private var tradeValue: Double = 0
    @State private var interestRate: Double = 7.99
    @State private var loanTerm: Int = 20
    
    init(boat: ShopifyBoat) {
        self.boat = boat
        _boatPrice = State(initialValue: boat.price)
        _downPayment = State(initialValue: boat.price * 0.10)
    }
    
    var monthlyPayment: Double {
        let principal = boatPrice - downPayment - tradeValue
        let monthlyRate = interestRate / (12 * 100)
        let numberOfPayments = loanTerm * 12
        
        guard principal > 0 else { return 0 }
        
        let payment = principal * 
            (monthlyRate * pow(1 + monthlyRate, Double(numberOfPayments))) /
            (pow(1 + monthlyRate, Double(numberOfPayments)) - 1)
        
        return payment
    }
    
    private func updateDownPayment() {
        downPayment = boatPrice * 0.10
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(boat.title)
                    .font(.title)
                    .foregroundColor(Theme.text)
                    .shadow(color: Theme.Shadows.text.color,
                           radius: Theme.Shadows.text.radius,
                           x: Theme.Shadows.text.x,
                           y: Theme.Shadows.text.y)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Starting at")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                    
                    Text("$\(boat.price, specifier: "%.2f")")
                        .font(.title2)
                        .foregroundColor(Theme.accent)
                }
                .padding()
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Theme.Shadows.card.color,
                       radius: Theme.Shadows.card.radius,
                       x: Theme.Shadows.card.x,
                       y: Theme.Shadows.card.y)
                
                // Payment Calculator
                VStack(alignment: .leading, spacing: 16) {
                    Text("Payment Calculator")
                        .font(.headline)
                        .foregroundColor(Theme.text)
                    
                    VStack(spacing: 12) {
                        // Boat Price
                        HStack {
                            Text("Boat Price")
                                .foregroundColor(Theme.textSecondary)
                            Spacer()
                            TextField("Boat Price", value: $boatPrice, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        // Down Payment
                        HStack {
                            Text("Down Payment")
                                .foregroundColor(Theme.textSecondary)
                            Spacer()
                            TextField("Down Payment", value: $downPayment, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        // Trade Value
                        HStack {
                            Text("Trade Value")
                                .foregroundColor(Theme.textSecondary)
                            Spacer()
                            TextField("Trade Value", value: $tradeValue, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        // Interest Rate
                        HStack {
                            Text("Interest Rate")
                                .foregroundColor(Theme.textSecondary)
                            Spacer()
                            TextField("Interest Rate", value: $interestRate, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("%")
                        }
                        
                        // Loan Term
                        HStack {
                            Text("Loan Term")
                                .foregroundColor(Theme.textSecondary)
                            Spacer()
                            Picker("Loan Term", selection: $loanTerm) {
                                Text("5 Years").tag(5)
                                Text("10 Years").tag(10)
                                Text("15 Years").tag(15)
                                Text("20 Years").tag(20)
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Monthly Payment
                        HStack {
                            Text("Monthly Payment")
                                .font(.headline)
                                .foregroundColor(Theme.text)
                            Spacer()
                            Text(monthlyPayment, format: .currency(code: "USD"))
                                .font(.title3)
                                .foregroundColor(Theme.accent)
                        }
                    }
                    .padding()
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Theme.Shadows.card.color,
                           radius: Theme.Shadows.card.radius,
                           x: Theme.Shadows.card.x,
                           y: Theme.Shadows.card.y)
                }
                
                // Other Button
                Button(action: {
                    withAnimation {
                        showingBottomLine.toggle()
                    }
                }) {
                    HStack {
                        Text("Other")
                            .font(.headline)
                        Spacer()
                        Text(showingBottomLine ? "▼" : "▶")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(Theme.text)
                    .padding()
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                if showingBottomLine {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bottom Line Price")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                        
                        if let bottomLine = boat.bottomLinePrice {
                            Text(bottomLine, format: .currency(code: "USD"))
                                .font(.title2)
                                .foregroundColor(Theme.accent)
                        } else {
                            Text("Call for Bottom Line Price")
                                .font(.headline)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(24)
        }
        .background(Theme.background)
        .navigationTitle("Price Sheet")
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                 to: nil, from: nil, for: nil)
                }
            }
        }
    }
} 