import SwiftUI

struct TrainingProgressView: View {
    @ObservedObject var progressManager: TrainingProgressManager
    
    var body: some View {
        List {
            Section {
                ForEach(progressManager.trainingItems) { item in
                    Button(action: {
                        withAnimation {
                            progressManager.toggleCompletion(for: item)
                        }
                    }) {
                        HStack {
                            Label("Status", systemImage: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .labelStyle(.iconOnly)
                                .foregroundColor(item.isCompleted ? Theme.accent : Theme.textSecondary)
                            
                            Text(item.title)
                                .foregroundColor(item.isCompleted ? Theme.textSecondary : Theme.text)
                            
                            Spacer()
                        }
                    }
                }
            } header: {
                Text("Progress: \(Int(progressManager.completionPercentage * 100))%")
            }
        }
    }
} 