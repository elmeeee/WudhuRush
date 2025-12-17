//
//  LevelCard.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

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
