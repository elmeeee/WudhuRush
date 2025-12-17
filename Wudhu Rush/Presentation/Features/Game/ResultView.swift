//
//  ResultView.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct ResultView: View {
    let score: Int
    let mistakes: Int
    let mode: GameMode
    let engine: GameEngine
    let onRestart: () -> Void
    let onHome: () -> Void
    let onNextLevel: (() -> Void)?
    
    @ObservedObject var localization = LocalizationManager.shared
    @StateObject private var userProfile = UserProfileManager.shared
    @State private var scoreSubmitted = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    if case .finished(let result) = engine.gameState, result == .loss {
                        GameTheme.error
                    } else {
                        GameTheme.primaryGreen
                    }
                    
                    VStack {
                        if case .finished(let result) = engine.gameState {
                            if result == .win {
                                Text(localization.feedback(\FeedbackData.level_completed).uppercased())
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundColor(GameTheme.goldHighlight)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            } else {
                                Text(localization.ui(\UIData.game_over).uppercased())
                                    .font(.system(size: 24, weight: .black))
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        } else {
                            Text(localization.ui(\UIData.completed).uppercased())
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(height: 100)
                
                VStack(spacing: 24) {
                    
                    if case .level = mode {
                        VStack(spacing: 4) {
                            Text(localization.ui(\UIData.final_score))
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
                    
                    HStack(spacing: 20) {
                        statBox(title: localization.ui(\UIData.mistake), value: "\(mistakes)", color: GameTheme.error)
                        
                        if case .level(let level) = mode {
                             statBox(title: localization.ui(\UIData.level), value: level.id, color: GameTheme.textDark)
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    // Next Level Button (if available and won)
                    if let onNext = onNextLevel, 
                       case .finished(let result) = engine.gameState, 
                       result == .win {
                        Button(action: onNext) {
                            HStack {
                                Text("Next Level")
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [GameTheme.primaryGreen, GameTheme.darkGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: GameTheme.primaryGreen.opacity(0.4), radius: 15, x: 0, y: 8)
                        }
                        .padding(.horizontal, 24)
                    }
                    
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
        .task {
            await submitScoreToLeaderboard()
        }
    }
    
    private func submitScoreToLeaderboard() async {
        // Only submit once
        guard !scoreSubmitted else { return }
        
        // Only submit for level mode (not practice)
        guard case .level(let levelData) = mode else { return }
        
        // Only submit if won
        guard case .finished(let result) = engine.gameState, result == .win else { return }
        
        scoreSubmitted = true
        
        do {
            try await FirebaseManager.shared.submitScore(
                playerName: userProfile.playerName,
                score: score,
                level: levelData.title
            )
            print("✅ Score submitted to leaderboard")
        } catch {
            print("❌ Failed to submit score: \(error)")
        }
    }
}

