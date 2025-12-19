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
    @StateObject private var gameCenter = GameCenterManager.shared
    @State private var playerName = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showAnonymousInput = false
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            GameTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo/Icon
                VStack(spacing: 16) {
                    Image("main-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 102, height: 127)
                        .shadow(color: GameTheme.primaryGreen.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Text("Wudhu Rush")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(GameTheme.textDark)
                    
                    Text("Learn Wudhu the fun way!")
                        .font(.title3)
                        .foregroundColor(GameTheme.textLight)
                }
                
                Spacer()
                
                if showAnonymousInput {
                    // Anonymous Name Input
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(showError ? Color.red : Color.clear, lineWidth: 2)
                                    .padding(.horizontal, 40)
                            )
                        
                        if showError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, 40)
                            .multilineTextAlignment(.center)
                        } else {
                            Text("Choose a unique name for the leaderboard")
                                .font(.caption)
                                .foregroundColor(GameTheme.textLight)
                                .padding(.horizontal, 40)
                        }
                    }
                } else {
                    // Login Options
                    VStack(spacing: 20) {
                        Text("Choose how to play")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(GameTheme.textDark)
                        
                        // Sign in with Game Center
                        Button(action: handleGameCenterSignIn) {
                            HStack(spacing: 12) {
                                Image(systemName: "gamecontroller.fill")
                                    .font(.title3)
                                Text("Sign in with Game Center")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [GameTheme.primaryGreen, GameTheme.darkGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: GameTheme.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 40)
                        .disabled(isLoading)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(GameTheme.textLight.opacity(0.3))
                                .frame(height: 1)
                            Text("or")
                                .font(.caption)
                                .foregroundColor(GameTheme.textLight)
                                .padding(.horizontal, 8)
                            Rectangle()
                                .fill(GameTheme.textLight.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 60)
                        
                        // Play as Guest
                        Button(action: {
                            withAnimation {
                                showAnonymousInput = true
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .font(.title3)
                                Text("Play as Guest")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(GameTheme.primaryGreen)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(GameTheme.primaryGreen, lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 40)
                        .disabled(isLoading)
                        
                        if showError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, 40)
                            .multilineTextAlignment(.center)
                        }
                    }
                }
                
                Spacer()
                
                // Continue Button (only show when anonymous input is visible)
                if showAnonymousInput {
                    Button(action: handleAnonymousContinue) {
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
    }
    
    private func handleGameCenterSignIn() {
        isLoading = true
        showError = false
        
        Task {
            // Authenticate with Game Center
            await gameCenter.authenticatePlayer()
            
            // Wait longer for authentication to complete
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            await MainActor.run {
                // Check if authentication succeeded
                if gameCenter.isAuthenticated, !gameCenter.playerName.isEmpty {
                    // Use Game Center player name
                    let gcPlayerName = gameCenter.playerName
                    
                    Task {
                        do {
                            // Sign in anonymously with Firebase
                            if userProfile.currentUser == nil {
                                try await userProfile.signInAnonymously()
                            }
                            
                            // Check if name is already taken by another user
                            let isTaken = try await userProfile.isPlayerNameTaken(gcPlayerName)
                            
                            if isTaken {
                                // Name is taken by another user - show error and allow manual input
                                await MainActor.run {
                                    showError = true
                                    errorMessage = "Your Game Center name '\(gcPlayerName)' is already taken by another user. Please enter a different name below."
                                    isLoading = false
                                    // Show anonymous input so user can enter different name
                                    showAnonymousInput = true
                                    playerName = "" // Clear any existing name
                                }
                                return
                            }
                            
                            // Name is available - set it
                            try await userProfile.setPlayerName(gcPlayerName)
                            
                            await MainActor.run {
                                isLoading = false
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
                } else {
                    // Authentication failed or player name not available
                    showError = true
                    errorMessage = "Failed to sign in with Game Center. Please try again or play as guest."
                    isLoading = false
                }
            }
        }
    }
    
    private func handleAnonymousContinue() {
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
