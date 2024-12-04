import SwiftUI

struct FinancingCalculatorView: View {
    @State private var boatPrice: Double = 200000
    @State private var downPayment: Double = 20000
    @State private var tradeValue: Double = 0
    @State private var interestRate: Double = 7.99
    @State private var loanTerm: Int = 20  // Default to 20 years
    
    private let termOptions = [5, 10, 15, 20]  // Available loan terms
    
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Calculator Card
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
                                    ForEach(termOptions, id: \.self) { term in
                                        Text("\(term) Years").tag(term)
                                    }
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
                    }
                    .padding()
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Theme.Shadows.card.color,
                           radius: Theme.Shadows.card.radius,
                           x: Theme.Shadows.card.x,
                           y: Theme.Shadows.card.y)
                }
                .padding(24)
            }
            .background(Theme.background)
            .navigationTitle("Financing Calculator")
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
} 