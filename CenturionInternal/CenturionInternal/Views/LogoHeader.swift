import SwiftUI
import UIKit

struct LogoHeader: View {
    var body: some View {
        HStack {
            Spacer()
            LogoImageView()
                .frame(height: 16)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            Spacer()
        }
        .padding(.top, 8)
        .background(Theme.card)
        .shadow(color: Theme.Shadows.card.color,
                radius: Theme.Shadows.card.radius,
                x: Theme.Shadows.card.x,
                y: Theme.Shadows.card.y)
    }
}

struct LogoImageView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "boardco_logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {}
} 