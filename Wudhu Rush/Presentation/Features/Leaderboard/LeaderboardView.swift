
import SwiftUI

struct LeaderboardView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var localization = LocalizationManager.shared
    
    // Mock Data
    let leaders: [(rank: Int, name: String, score: Int)] = [
        (1, "Aisha", 1500),
        (2, "Yusuf", 1420),
        (3, "Fatima", 1350),
        (4, "Omar", 1200),
        (5, "Hassan", 1100),
        (6, "You", 950),
        (7, "Zainab", 900)
    ]
    
    var body: some View {
        ZStack {
            GameTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Nav
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(GameTheme.primaryGreen)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    Spacer()
                    Text(localization.ui(\UIData.leaderboard))
                        .font(.headline)
                        .foregroundColor(GameTheme.primaryGreen)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding()
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(leaders, id: \.name) { player in
                            LeaderRow(rank: player.rank, name: player.name, score: player.score)
                        }
                    }
                    .padding()
                }
                
                // Footer
                VStack {
                    Text(localization.ui(\UIData.offline_mode))
                        .font(.caption2)
                        .foregroundColor(GameTheme.textLight)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
}

struct LeaderRow: View {
    let rank: Int
    let name: String
    let score: Int
    
    var body: some View {
        HStack {
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(GameTheme.gold.opacity(0.2))
                        .frame(width: 40, height: 40)
                }
                Text("\(rank)")
                    .font(.headline)
                    .foregroundColor(rank <= 3 ? GameTheme.gold : GameTheme.textLight)
            }
            .frame(width: 50)
            
            Text(name)
                .font(.body)
                .fontWeight(name == "You" ? .bold : .medium)
                .foregroundColor(GameTheme.textDark)
            
            Spacer()
            
            Text("\(score)")
                .monospacedDigit()
                .fontWeight(.bold)
                .foregroundColor(GameTheme.primaryGreen)
        }
        .padding()
        .background(name == "You" ? GameTheme.lightGreen : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
