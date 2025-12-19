//
//  GameCenterManager.swift
//  Wudhu Rush
//
//  Created by Elmee on 19/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import Foundation
import GameKit
import SwiftUI
import Combine

@MainActor
final class GameCenterManager: NSObject, ObservableObject {
    static let shared = GameCenterManager()
    
    @Published var isAuthenticated = false
    @Published var localPlayer: GKLocalPlayer?
    @Published var playerName: String = ""
    @Published var playerID: String = ""
    
    // Achievement IDs - Define your achievements in App Store Connect
    enum AchievementID: String {
        case firstGame = "com.wudhurush.achievement.firstgame"
        case play10Games = "com.wudhurush.achievement.play10games"
        case play50Games = "com.wudhurush.achievement.play50games"
        case score1000 = "com.wudhurush.achievement.score1000"
        case score5000 = "com.wudhurush.achievement.score5000"
        case perfectGame = "com.wudhurush.achievement.perfectgame"
        case allLevels = "com.wudhurush.achievement.alllevels"
    }
    
    private override init() {
        super.init()
    }
    
    // MARK: - Authentication
    
    func authenticatePlayer() async {
        let player = GKLocalPlayer.local
        
        // Set authentication handler
        player.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                // Check if there's an error that's NOT the "not recognized" error
                if let error = error, !error.localizedDescription.contains("not recognized by Game Center") {
                    print("Game Center authentication error: \(error.localizedDescription)")
                    self.isAuthenticated = false
                    return
                }
                
                if let viewController = viewController {
                    // Present the Game Center login view
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(viewController, animated: true)
                    }
                } else if player.isAuthenticated {
                    // Player is authenticated - this is what matters!
                    self.isAuthenticated = true
                    self.localPlayer = player
                    self.playerName = player.displayName
                    self.playerID = player.gamePlayerID
                    
                    print("✅ Game Center authenticated: \(player.displayName)")
                    
                    // Skip loading achievements if app not registered (development mode)
                    // await self.loadAchievements()
                } else {
                    self.isAuthenticated = false
                }
            }
        }
    }
    
    // MARK: - Achievements
    
    func reportAchievement(_ achievementID: AchievementID, percentComplete: Double = 100.0) async {
        guard isAuthenticated else {
            return // Silently skip if not authenticated
        }
        
        let achievement = GKAchievement(identifier: achievementID.rawValue)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        
        do {
            try await GKAchievement.report([achievement])
            print("✅ Achievement reported: \(achievementID.rawValue)")
        } catch {
            // Silently ignore if app not registered with Game Center
            if !error.localizedDescription.contains("not recognized by Game Center") {
                print("❌ Failed to report achievement: \(error.localizedDescription)")
            }
        }
    }
    
    func loadAchievements() async {
        guard isAuthenticated else { return }
        
        do {
            let achievements = try await GKAchievement.loadAchievements()
            print("📊 Loaded \(achievements.count) achievements")
            
            for achievement in achievements {
                print("  - \(achievement.identifier): \(achievement.percentComplete)%")
            }
        } catch {
            // Silently ignore if app not registered
            if !error.localizedDescription.contains("not recognized by Game Center") {
                print("❌ Failed to load achievements: \(error.localizedDescription)")
            }
        }
    }
    
    func resetAchievements() async {
        guard isAuthenticated else { return }
        
        do {
            try await GKAchievement.resetAchievements()
            print("✅ Achievements reset")
        } catch {
            print("❌ Failed to reset achievements: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Leaderboards
    
    func submitScore(_ score: Int, to leaderboardID: String = "com.wudhurush.leaderboard.main") async {
        guard isAuthenticated else {
            return // Silently skip if not authenticated
        }
        
        do {
            try await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [leaderboardID]
            )
            print("✅ Score submitted to Game Center: \(score)")
        } catch {
            // Silently ignore if app not registered with Game Center
            if !error.localizedDescription.contains("not recognized by Game Center") {
                print("❌ Failed to submit score: \(error.localizedDescription)")
            }
        }
    }
    
    func showLeaderboard() {
        guard isAuthenticated else { return }
        
        let viewController = GKGameCenterViewController(state: .leaderboards)
        viewController.gameCenterDelegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(viewController, animated: true)
        }
    }
    
    func showAchievements() {
        guard isAuthenticated else { return }
        
        let viewController = GKGameCenterViewController(state: .achievements)
        viewController.gameCenterDelegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(viewController, animated: true)
        }
    }
    
    // MARK: - Helper Functions
    
    func checkAndReportAchievements(gamesPlayed: Int, totalScore: Int, bestScore: Int, allLevelsCompleted: Bool) async {
        // First game
        if gamesPlayed >= 1 {
            await reportAchievement(.firstGame)
        }
        
        // Play 10 games
        if gamesPlayed >= 10 {
            await reportAchievement(.play10Games)
        }
        
        // Play 50 games
        if gamesPlayed >= 50 {
            await reportAchievement(.play50Games)
        }
        
        // Total score milestones
        if totalScore >= 1000 {
            await reportAchievement(.score1000)
        }
        
        if totalScore >= 5000 {
            await reportAchievement(.score5000)
        }
        
        // Perfect game (no mistakes)
        if bestScore >= 1000 {
            await reportAchievement(.perfectGame)
        }
        
        // All levels completed
        if allLevelsCompleted {
            await reportAchievement(.allLevels)
        }
    }
}

// MARK: - GKGameCenterControllerDelegate

extension GameCenterManager: GKGameCenterControllerDelegate {
    nonisolated func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        Task { @MainActor in
            gameCenterViewController.dismiss(animated: true)
        }
    }
}
