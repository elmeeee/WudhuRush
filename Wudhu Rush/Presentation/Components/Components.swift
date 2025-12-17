
import SwiftUI

// MARK: - Primary Button
struct WRButton: View {
    let title: String
    let subtitle: String?
    let icon: String
    let action: () -> Void
    var style: Style = .primary
    
    enum Style {
        case primary
        case secondary
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(style == .primary ? Color.white.opacity(0.2) : GameTheme.lightGreen)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(style == .primary ? .white : GameTheme.primaryGreen)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(style == .primary ? .white : GameTheme.primaryGreen)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(style == .primary ? .white.opacity(0.8) : GameTheme.textLight)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(style == .primary ? .white.opacity(0.6) : GameTheme.textLight.opacity(0.5))
            }
            .padding()
            .frame(height: 80)
            .background(style == .primary ? GameTheme.primaryGreen : Color.white)
            .cornerRadius(20)
            .shadow(color: style == .primary ? GameTheme.primaryGreen.opacity(0.3) : Color.black.opacity(0.05), radius: 15, x: 0, y: 10)
            .scaleEffect(1.0)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Decorative Background
struct WRBackground: View {
    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()
            
            GeometryReader { proxy in
                Circle()
                    .fill(GameTheme.lightGreen)
                    .frame(width: 300, height: 300)
                    .position(x: proxy.size.width * 0.85, y: proxy.size.height * 0.1)
                    .opacity(0.6)
                    .blur(radius: 40)
                
                Circle()
                    .fill(GameTheme.gold.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .position(x: proxy.size.width * 0.1, y: proxy.size.height * 0.9)
                    .blur(radius: 60)
            }
        }
    }
}
