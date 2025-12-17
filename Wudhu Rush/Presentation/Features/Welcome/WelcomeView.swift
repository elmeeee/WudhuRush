//
//  WelcomeView.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    @StateObject private var userProfile = UserProfileManager.shared
    @State private var playerName = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            GameTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo/Icon
                VStack(spacing: 16) {
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 80))
                        .foregroundColor(GameTheme.primaryGreen)
                    
                    Text("Wudhu Rush")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(GameTheme.textDark)
                    
                    Text("Learn Wudhu the fun way!")
                        .font(.title3)
                        .foregroundColor(GameTheme.textLight)
                }
                
                Spacer()
                
                // Name Input
                VStack(spacing: 20) {
                    Text("What's your name?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(GameTheme.textDark)
                    
                    TextField("Enter your name", text: $playerName)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 40)
                        .disabled(isLoading)
                    
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                // Continue Button
                Button(action: handleContinue) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Let's Start!")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [GameTheme.primaryGreen, GameTheme.primaryGreen.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: GameTheme.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .disabled(isLoading)
            }
        }
    }
    
    private func handleContinue() {
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            showError = true
            errorMessage = "Please enter your name"
            return
        }
        
        isLoading = true
        showError = false
        
        Task {
            do {
                // Sign in anonymously if not already signed in
                if userProfile.currentUser == nil {
                    try await userProfile.signInAnonymously()
                }
                
                // Set player name
                try await userProfile.setPlayerName(trimmedName)
                
                await MainActor.run {
                    onComplete()
                }
            } catch {
                await MainActor.run {
                    showError = true
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    WelcomeView(onComplete: {})
}
