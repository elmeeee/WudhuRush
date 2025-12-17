//
//  WRBackground.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct WRBackground: View {
    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()
            
            GeometryReader { proxy in
                Circle()
                    .fill(GameTheme.lightGreen)
                    .frame(width: 300, height: 300)
                    .position(x: proxy.size.width * 0.85, y: proxy.size.height * 0.1)
                    .opacity(0.6)
                    .blur(radius: 40)
                
                Circle()
                    .fill(GameTheme.gold.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .position(x: proxy.size.width * 0.1, y: proxy.size.height * 0.9)
                    .blur(radius: 60)
            }
        }
    }
}
