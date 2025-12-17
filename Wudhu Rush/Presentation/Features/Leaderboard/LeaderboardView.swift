//
//  LeaderboardView.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct LeaderboardView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var localization = LocalizationManager.shared
    
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
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(leaders, id: \.name) { player in
                            LeaderRow(rank: player.rank, name: player.name, score: player.score)
                        }
                    }
                    .padding()
                }
                
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

