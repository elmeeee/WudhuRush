
import SwiftUI

struct ResultView: View {
    let score: Int
    let mistakes: Int
    let mode: GameMode
    let onRestart: () -> Void
    let onHome: () -> Void
    
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        ZStack {
            // Card
            VStack(spacing: 0) {
                // Top Banner
                ZStack {
                    GameTheme.primaryGreen
                    VStack {
                        if case .level = mode {
                            Text(localization.feedback(\FeedbackData.level_completed).uppercased())
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(GameTheme.goldHighlight)
                                .multilineTextAlignment(.center)
                                .padding()
                        } else {
                            Text(localization.ui(\UIData.completed).uppercased())
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(height: 100)
                
                // Content
                VStack(spacing: 24) {
                    
                    // Score Display
                    if case .level = mode {
                        VStack(spacing: 4) {
                            Text("FINAL SCORE") // Maybe localized? Not in JSON currently explicitly, can use "Score" if added or hardcode for now
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(GameTheme.textLight)
                            Text("\(score)")
                                .font(.system(size: 56, weight: .heavy, design: .rounded))
                                .foregroundColor(GameTheme.primaryGreen)
                                .shadow(color: GameTheme.primaryGreen.opacity(0.1), radius: 5, x: 0, y: 5)
                        }
                        .padding(.top, 20)
                    } else {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.system(size: 60))
                            .foregroundColor(GameTheme.primaryGreen)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                    }
                    
                    // Grid Stats
                    HStack(spacing: 20) {
                        statBox(title: localization.ui(\UIData.mistake), value: "\(mistakes)", color: GameTheme.error)
                        
                        if case .level(let level) = mode {
                             statBox(title: "Level", value: level.id, color: GameTheme.textDark)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Actions
                    HStack(spacing: 16) {
                        Button(action: onHome) {
                            HStack {
                                Image(systemName: "house.fill")
                                Text(localization.ui(\UIData.home))
                            }
                            .font(.headline)
                            .foregroundColor(GameTheme.textDark)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(GameTheme.lightGreen)
                            .cornerRadius(16)
                        }
                        
                        Button(action: onRestart) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text(localization.ui(\UIData.play_again))
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(GameTheme.primaryGreen)
                            .cornerRadius(16)
                            .shadow(color: GameTheme.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
                .background(Color.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: Color.black.opacity(0.2), radius: 30, x: 0, y: 15)
            .padding(20)
            .frame(maxWidth: 400)
        }
    }
    
    private func statBox(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(title.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(GameTheme.textLight)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(GameTheme.background)
        .cornerRadius(12)
    }
}
