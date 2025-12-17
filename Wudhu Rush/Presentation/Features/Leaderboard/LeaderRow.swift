//
//  LeaderRow.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct LeaderRow: View {
    let rank: Int
    let name: String
    let score: Int
    
    var medalColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .clear
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank with medal for top 3
            ZStack {
                if rank <= 3 {
                    Image(systemName: "medal.fill")
                        .font(.system(size: 32))
                        .foregroundColor(medalColor)
                }
                
                Text("\(rank)")
                    .font(.system(size: rank <= 3 ? 14 : 18, weight: .bold))
                    .foregroundColor(rank <= 3 ? .white : GameTheme.textDark)
                    .frame(width: 40)
            }
            
            // Player name
            Text(name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(GameTheme.textDark)
            
            Spacer()
            
            // Score
            Text("\(score)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(GameTheme.primaryGreen)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
