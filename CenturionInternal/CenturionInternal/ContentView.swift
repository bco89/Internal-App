//
//  ContentView.swift
//  CenturionInternal
//
//  Created by Collin Jensen on 12/3/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @StateObject private var trainingProgressManager = TrainingProgressManager()
    
    var body: some View {
        if isAuthenticated {
            TabView {
                InventoryView()
                    .tabItem {
                        Label("Inventory", systemImage: "ferry.fill")
                    }
                
                TrainingView()
                    .tabItem {
                        Label("Training", systemImage: "graduationcap.fill")
                    }
                
                FinancingCalculatorView()
                    .tabItem {
                        Label("Calculator", systemImage: "dollarsign.circle.fill")
                    }
                
                QuickSpecsView()
                    .tabItem {
                        Label("Specs", systemImage: "list.clipboard.fill")
                    }
                
                GoalsView(isAuthenticated: $isAuthenticated)
                    .tabItem {
                        Label("Goals", systemImage: "chart.bar.fill")
                    }
            }
            .environmentObject(trainingProgressManager)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        isAuthenticated = false
                    }
                }
            }
        } else {
            LoginView(isAuthenticated: $isAuthenticated)
        }
    }
}

#Preview {
    ContentView()
}
