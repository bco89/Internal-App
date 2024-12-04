import SwiftUI

struct Objection: Identifiable {
    let id = UUID()
    let objection: String
    let response: String
    let tips: [String]
}

struct ObjectionHandlingView: View {
    let objections = [
        Objection(
            objection: "The price is too high",
            response: "I understand price is a significant consideration. Let's look at the value you're getting with a Centurion.",
            tips: [
                "Focus on long-term value and quality",
                "Highlight exclusive features",
                "Discuss financing options",
                "Compare total cost of ownership"
            ]
        ),
        Objection(
            objection: "I need to think about it",
            response: "That's completely understandable. What specific aspects would you like to think more about?",
            tips: [
                "Identify specific concerns",
                "Offer additional information",
                "Schedule a follow-up",
                "Provide comparison materials"
            ]
        ),
        Objection(
            objection: "I want to look at other brands",
            response: "That's a great way to make an informed decision. Let me show you how Centurion stands out in key areas.",
            tips: [
                "Highlight Centurion's unique features",
                "Show performance comparisons",
                "Discuss build quality differences",
                "Share customer testimonials"
            ]
        )
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(objections) { objection in
                    ObjectionCard(objection: objection)
                }
            }
            .padding()
        }
        .navigationTitle("Objection Handling")
    }
}

struct ObjectionCard: View {
    let objection: Objection
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { withAnimation { isExpanded.toggle() }}) {
                HStack {
                    Text(objection.objection)
                        .font(.headline)
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
                VStack(alignment: .leading, spacing: 16) {
                    Text("Response:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.accent)
                    
                    Text(objection.response)
                        .foregroundColor(Theme.text)
                    
                    Text("Key Tips:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.accent)
                    
                    ForEach(objection.tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(Theme.accent)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            Text(tip)
                        }
                        .foregroundColor(Theme.text)
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