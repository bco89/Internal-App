import SwiftUI

enum AppTheme {
    // Colors
    static let background = Color.black
    static let text = Color.white
    static let accent = Color(hex: "D4AF37") // Gold/Amber
    static let secondaryBackground = Color(hex: "1A1A1A") // Dark gray
    static let cardBackground = Color(hex: "121212") // Slightly lighter black
    
    // Font Sizes
    static let titleFont = Font.custom("SF Pro Display", size: 28).weight(.bold)
    static let headlineFont = Font.custom("SF Pro Display", size: 20).weight(.semibold)
    static let bodyFont = Font.custom("SF Pro Text", size: 16)
    static let captionFont = Font.custom("SF Pro Text", size: 14)
    
    // Button Styles
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(headlineFont)
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(accent)
                .cornerRadius(8)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        }
    }
    
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(bodyFont)
                .foregroundColor(text)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(secondaryBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(accent, lineWidth: 1)
                )
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        }
    }
}

// Helper for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 