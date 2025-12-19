//
//  WudhuRushApp.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI
import FirebaseCore

@main
struct WudhuRushApp: App {
    @State private var showSplash = true
    
    init() {
        // Configure Firebase first
        FirebaseApp.configure()
        
        // Then initialize managers
        _ = FirebaseManager.shared
        _ = UserProfileManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                } else {
                    HomeView()
                        .transition(.opacity)
                }
            }
        }
    }
}
