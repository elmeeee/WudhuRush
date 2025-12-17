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
