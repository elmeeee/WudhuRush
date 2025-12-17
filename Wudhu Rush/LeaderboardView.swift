
import SwiftUI

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    
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
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(GameTheme.primaryGreen)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Leaderboard")
                        .font(.headline)
                        .foregroundColor(GameTheme.primaryGreen)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding()
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(leaders, id: \.name) { player in
                            HStack {
                                Text("\(player.rank)")
                                    .font(.headline)
                                    .foregroundColor(player.rank <= 3 ? GameTheme.goldAccent : .gray)
                                    .frame(width: 30)
                                Text(player.name)
                                    .font(.body)
                                    .fontWeight(player.name == "You" ? .bold : .regular)
                                    .foregroundColor(.black)
                                Spacer()
                                Text("\(player.score)")
                                    .monospacedDigit() // Fixed: view modifier, not font modifier
                                    .fontWeight(.bold)
                                    .foregroundColor(GameTheme.primaryGreen)
                            }
                            .padding()
                            .background(player.name == "You" ? GameTheme.softGreen : Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding()
                }
                VStack {
                    Text("Offline Mode")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("Connect to internet for global rankings")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
}
