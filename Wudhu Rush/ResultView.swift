
import SwiftUI

struct ResultView: View {
    let score: Int
    let mistakes: Int
    let onRestart: () -> Void
    let onHome: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Text(score >= 500 ? "MashaAllah!" : "Good Effort!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(GameTheme.primaryGreen)
                    .padding(.top, 20)
                VStack(spacing: 8) {
                    Text("Your Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Text("\(score)")
                        .font(.system(size: 60, weight: .heavy, design: .rounded))
                        .foregroundColor(GameTheme.goldAccent)
                }
                VStack(spacing: 12) {
                    statRow(icon: "xmark.circle.fill", label: "Mistakes", value: "\(mistakes)", color: GameTheme.errorRed)
                    statRow(icon: "star.fill", label: "Perfect Run", value: mistakes == 0 ? "Yes" : "No", color: GameTheme.goldAccent)
                }
                .padding()
                .background(GameTheme.softGreen)
                .cornerRadius(16)
                HStack(spacing: 20) {
                    Button(action: onHome) {
                        VStack {
                            Image(systemName: "house.fill")
                                .font(.title2)
                            Text("Home")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .foregroundColor(GameTheme.primaryGreen)
                        .background(GameTheme.softGreen)
                        .cornerRadius(16)
                    }
                    Button(action: onRestart) {
                        VStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                            Text("Play Again")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .foregroundColor(.white)
                        .background(GameTheme.primaryGreen)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 340)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
    
    private func statRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(label)
                .foregroundColor(.black.opacity(0.7))
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}
