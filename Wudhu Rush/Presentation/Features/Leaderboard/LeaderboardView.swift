//
//  LeaderboardView.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            GameTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
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
                
                // Leaderboard List
                if firebaseManager.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else if firebaseManager.leaderboard.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundColor(GameTheme.primaryGreen.opacity(0.3))
                        
                        Text("No scores yet")
                            .font(.title3)
                            .foregroundColor(GameTheme.textLight)
                        
                        Text("Play a level to get on the leaderboard!")
                            .font(.subheadline)
                            .foregroundColor(GameTheme.textLight.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(firebaseManager.leaderboard.enumerated()), id: \.element.id) { index, entry in
                                LeaderRow(
                                    rank: index + 1,
                                    name: entry.playerName,
                                    score: entry.score
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadLeaderboard()
        }
    }
    
    private func loadLeaderboard() async {
        do {
            _ = try await firebaseManager.fetchLeaderboard(limit: 100)
        } catch {
            print("Error loading leaderboard: \(error)")
        }
    }
}
