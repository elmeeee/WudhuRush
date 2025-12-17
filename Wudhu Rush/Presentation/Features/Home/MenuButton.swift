//
//  MenuButton.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

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
