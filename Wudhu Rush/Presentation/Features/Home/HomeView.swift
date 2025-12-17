
import SwiftUI

struct HomeView: View {
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var navigateToGame = false
    @State private var selectedLevel: LevelData?
    @State private var gameMode: GameMode = .practice
    
    // Supported Languages
    let languages = [
        ("en", "🇺🇸"), ("id", "🇮🇩"), ("ms", "🇲🇾"), 
        ("ja", "🇯🇵"), ("th", "🇹🇭"), ("es", "🇪🇸")
    ]
    
    enum NavigationDestination: Hashable {
        case game(GameMode)
        case leaderboard
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                WRBackground()
                
                VStack(spacing: 0) {
                    
                    // Top Bar: LEvel / Language
                    HStack {
                        Spacer()
                        Menu {
                            ForEach(languages, id: \.0) { lang in
                                Button(action: {
                                    localization.setLanguage(lang.0)
                                }) {
                                    Text("\(lang.1) \(lang.0.uppercased())")
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "globe")
                                Text(localization.languageCode.uppercased())
                                    .fontWeight(.bold)
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Capsule())
                            .foregroundColor(GameTheme.primaryGreen)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    // Header Section
                    VStack(spacing: 16) {
                        Circle()
                            .fill(GameTheme.lightGreen)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(GameTheme.primaryGreen)
                            )
                            .shadow(color: GameTheme.primaryGreen.opacity(0.2), radius: 15, x: 0, y: 8)
                            
                        Text("Wudhu Rush")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundColor(GameTheme.primaryGreen)
                        
                        Text(localization.ui(\UIData.home)) // Or some other description if available?
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(GameTheme.textDark.opacity(0.6))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(20)
                    }
                    .padding(.bottom, 30)
                    
                    // Levels Scroll View
                    VStack(alignment: .leading, spacing: 10) {
                        Text(localization.ui(\UIData.time_attack))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(GameTheme.textLight)
                            .padding(.leading, 30)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(localization.content?.levels ?? []) { level in
                                    NavigationLink(value: NavigationDestination.game(.level(level))) {
                                        LevelCard(level: level)
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 20) // Shadow space
                        }
                    }
                    
                    // Practice & Leaderboard
                    VStack(spacing: 16) {
                        NavigationLink(value: NavigationDestination.game(.practice)) {
                            MenuButton(
                                icon: "book.fill",
                                title: localization.ui(\UIData.practice),
                                subtitle: localization.content?.endless_mode.title ?? "Endless" // Fallback
                            )
                        }
                        
                        NavigationLink(value: NavigationDestination.leaderboard) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                Text(localization.ui(\UIData.leaderboard))
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(GameTheme.primaryGreen)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 60)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)

                    Text("v2.2 • Localization Ready")
                        .font(.caption2)
                        .foregroundColor(GameTheme.textLight)
                        .padding(.bottom, 10)
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .game(let mode):
                    GameView(mode: mode)
                case .leaderboard:
                    LeaderboardView()
                }
            }
        }
    }
}

struct LevelCard: View {
    let level: LevelData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(level.id)
                    .font(.caption2)
                    .fontWeight(.black)
                    .padding(6)
                    .background(GameTheme.lightGreen)
                    .foregroundColor(GameTheme.primaryGreen)
                    .clipShape(Circle())
                Spacer()
                Text("\(level.time_limit)s")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(GameTheme.textLight)
            }
            
            Text(level.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(GameTheme.textDark)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            Text(level.description)
                .font(.caption)
                .foregroundColor(GameTheme.textLight)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
        .padding()
        .frame(width: 160, height: 140)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(GameTheme.lightGreen)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(GameTheme.primaryGreen)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(GameTheme.primaryGreen)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(GameTheme.textLight)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(GameTheme.textLight)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
