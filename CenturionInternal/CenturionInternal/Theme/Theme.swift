import SwiftUI

enum Theme {
    static let background = Color.white
    static let text = Color.black
    static let textSecondary = Color.gray
    static let accent = Color("AccentColor")
    static let card = Color.white
    static let cardShadow = Color.black.opacity(0.1)
    
    struct Shadows {
        static let card = Shadow(color: cardShadow, radius: 10, y: 4)
        static let text = Shadow(color: cardShadow, radius: 1, y: 1)
    }
    
    static func button(_ isSecondary: Bool = false) -> some View {
        Group {
            if isSecondary {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(accent, lineWidth: 1)
                    .background(card)
                    .shadow(radius: 4)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(accent)
                    .shadow(radius: 4)
            }
        }
    }
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
} 