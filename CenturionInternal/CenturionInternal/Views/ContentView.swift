import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            InventoryView()
                .tabItem {
                    Text("Inventory")
                }
            
            TrainingView()
                .tabItem {
                    Text("Training")
                }
            
            FinancingCalculatorView()
                .tabItem {
                    Text("Calculator")
                }
            
            QuickSpecsView()
                .tabItem {
                    Text("Specs")
                }
            
            GoalsView()
                .tabItem {
                    Text("Goals")
                }
        }
    }
} 