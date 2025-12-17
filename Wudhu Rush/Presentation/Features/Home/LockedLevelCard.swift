//
//  LockedLevelCard.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct LockedLevelCard: View {
    let level: LevelData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(GameTheme.textLight.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(GameTheme.textLight)
                }
                Spacer()
            }
            
            Text(level.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(GameTheme.textLight)
                .multilineTextAlignment(.leading)
            
            Text(LocalizationManager.shared.ui(\UIData.locked_level))
                .font(.caption)
                .foregroundColor(GameTheme.textLight.opacity(0.6))
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(width: 160, height: 140)
        .background(Color.white.opacity(0.6))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}
