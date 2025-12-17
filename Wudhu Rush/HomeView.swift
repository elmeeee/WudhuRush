
import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                GameTheme.background
                    .ignoresSafeArea()
                
                GeometryReader { proxy in
                    Circle()
                        .fill(GameTheme.softGreen)
                        .frame(width: 300, height: 300)
                        .position(x: proxy.size.width * 0.8, y: proxy.size.height * 0.1)
                        .opacity(0.5)
                    
                    Circle()
                        .fill(GameTheme.goldAccent.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .position(x: proxy.size.width * 0.1, y: proxy.size.height * 0.9)
                }
                
                VStack(spacing: 40) {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("Wudhu Rush")
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundColor(GameTheme.primaryGreen)
                        Text("Susun wudhu dengan benar")
                            .font(.subheadline)
                            .foregroundColor(GameTheme.primaryGreen.opacity(0.7))
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(GameTheme.softGreen)
                            .cornerRadius(20)
                    }
                    Spacer()
                    VStack(spacing: 20) {
                        NavigationLink(destination: GameView().navigationBarHidden(true)) {
                            HomeButton(title: "Time Attack", subtitle: "Race against time", icon: "play.fill", isPrimary: true)
                        }
                        NavigationLink(destination: LeaderboardView()) { // Practice Placeholder
                             HomeButton(title: "Practice", subtitle: "Learn at your own pace", icon: "book.fill", isPrimary: false)
                        }
                        NavigationLink(destination: LeaderboardView()) {
                            HomeButton(title: "Leaderboard", subtitle: "See global rankings", icon: "chart.bar.fill", isPrimary: false, isSmall: true)
                        }
                    }
                    .padding(.horizontal, 30)
                    Spacer()
                    Text("v1.0.0 • Indie Game")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.4))
                        .padding(.bottom, 20)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct HomeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isPrimary: Bool
    var isSmall: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isPrimary ? Color.white.opacity(0.2) : GameTheme.softGreen)
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isPrimary ? .white : GameTheme.primaryGreen)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isPrimary ? .white : GameTheme.primaryGreen)
                if !isSmall {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(isPrimary ? .white.opacity(0.8) : .gray)
                }
            }
            Spacer()
            if !isSmall {
                Image(systemName: "chevron.right")
                    .foregroundColor(isPrimary ? .white.opacity(0.6) : .gray.opacity(0.4))
            }
        }
        .padding()
        .frame(height: isSmall ? 60 : 80)
        .background(isPrimary ? GameTheme.primaryGreen : Color.white)
        .cornerRadius(20)
        .shadow(color: GameTheme.primaryGreen.opacity(isPrimary ? 0.3 : 0.05), radius: 15, x: 0, y: 10)
    }
}
