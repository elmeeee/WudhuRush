//
//  HomeView.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//


import SwiftUI

struct HomeView: View {
    @ObservedObject private var localization = LocalizationManager.shared
    @StateObject private var userProfile = UserProfileManager.shared
    @ObservedObject private var levelProgress = LevelProgressManager.shared
    @State private var navigateToGame = false
    @State private var selectedLevel: LevelData?
    @State private var gameMode: GameMode = .practice
    @State private var showSignOutConfirmation = false
    
    let languages = [
        ("en", "🇺🇸"), ("id", "🇮🇩"), ("ms", "🇲🇾"), 
        ("ja", "🇯🇵"), ("th", "🇹🇭"), ("es", "🇪🇸")
    ]
    
    var body: some View {
        Group {
            if !userProfile.hasSetName {
                WelcomeView {
                    // User completed welcome
                }
            } else {
                mainContent
            }
        }
        .task {
            // Restore session if user has persisted data
            await userProfile.restoreSessionIfNeeded()
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        NavigationStack {
            ZStack {
                WRBackground()
                
                VStack(spacing: 0) {
                    
                    HStack {
                        // Sign Out Button (Icon Only)
                        Button(action: {
                            showSignOutConfirmation = true
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title3)
                                .foregroundColor(GameTheme.primaryGreen)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .padding(.leading, 20)
                        .padding(.top, 10)
                        
                        Spacer()
                        
                        // Language Selector
                        Menu {
                            ForEach(languages, id: \.0) { lang in
                                Button(action: {
                                    localization.setLanguage(lang.0)
                                }) {
                                    Text("\(lang.1) \(lang.0.uppercased())")
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "globe")
                                Text(localization.languageCode.uppercased())
                                    .fontWeight(.bold)
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Capsule())
                            .foregroundColor(GameTheme.primaryGreen)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image("main-icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 102, height: 127)
                            .shadow(color: GameTheme.primaryGreen.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                        Text("Wudhu Rush")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundColor(GameTheme.primaryGreen)
                        
                        Text(localization.ui(\UIData.home))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(GameTheme.textDark.opacity(0.6))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(20)
                    }
                    .padding(.bottom, 30)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(localization.ui(\UIData.time_attack))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(GameTheme.textLight)
                            .padding(.leading, 30)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                let levels = localization.content?.levels ?? []
                                ForEach(Array(levels.enumerated()), id: \.element.id) { index, level in
                                    let isLocked = levelProgress.isLocked(index: index)
                                    
                                    if isLocked {
                                        LockedLevelCard(level: level)
                                    } else {
                                        NavigationLink(value: NavigationDestination.game(.level(level))) {
                                            LevelCard(level: level)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 20)
                        }
                    }
                    
                    VStack(spacing: 16) {
                        NavigationLink(value: NavigationDestination.game(.practice)) {
                            MenuButton(
                                icon: "book.fill",
                                title: localization.ui(\UIData.practice),
                                subtitle: localization.content?.endless_mode.title ?? ""
                            )
                        }
                        
                        NavigationLink(value: NavigationDestination.leaderboard) {
                            MenuButton(
                                icon: "chart.bar.fill",
                                title: localization.ui(\UIData.leaderboard),
                                subtitle: localization.ui(\UIData.view_top_scores)
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .game(let mode):
                    GameView(mode: mode)
                case .leaderboard:
                    LeaderboardView()
                }
            }
        }
        .alert("Sign Out?", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                do {
                    try userProfile.signOut()
                } catch {
                    print("Error signing out: \(error)")
                }
            }
        } message: {
            Text("All your progress and scores will be permanently deleted.")
        }
    }
}
