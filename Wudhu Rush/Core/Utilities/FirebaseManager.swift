//
//  FirebaseManager.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Combine

struct LeaderboardEntry: Codable, Identifiable {
    @DocumentID var id: String?
    let playerName: String
    let score: Int
    let totalScore: Int
    let gamesPlayed: Int
    let bestScore: Int
    let level: String
    let timestamp: Date
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case playerName = "player_name"
        case score
        case totalScore = "total_score"
        case gamesPlayed = "games_played"
        case bestScore = "best_score"
        case level
        case timestamp
        case userId = "user_id"
    }
}

@MainActor
final class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    private let leaderboardCollection = "leaderboard"
    
    private init() {
        // Firebase already configured in WudhuRushApp
    }
    
    // MARK: - Submit Score
    
    func submitScore(playerName: String, score: Int, level: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Check if user already has a leaderboard entry
        let query = db.collection(leaderboardCollection)
            .whereField("user_id", isEqualTo: userId)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        
        if let existingDoc = snapshot.documents.first {
            // Update existing entry
            let data = existingDoc.data()
            let currentTotalScore = data["total_score"] as? Int ?? 0
            let currentGamesPlayed = data["games_played"] as? Int ?? 0
            let currentBestScore = data["best_score"] as? Int ?? 0
            
            let newTotalScore = currentTotalScore + score
            let newGamesPlayed = currentGamesPlayed + 1
            let newBestScore = max(currentBestScore, score)
            
            try await existingDoc.reference.updateData([
                "player_name": playerName, // Update in case name changed
                "score": newTotalScore, // Main score for sorting (total)
                "total_score": newTotalScore,
                "games_played": newGamesPlayed,
                "best_score": newBestScore,
                "level": level, // Last played level
                "timestamp": FieldValue.serverTimestamp()
            ])
            
        } else {
            // Create new entry
            let entry: [String: Any] = [
                "player_name": playerName,
                "score": score, // Main score for sorting
                "total_score": score,
                "games_played": 1,
                "best_score": score,
                "level": level,
                "timestamp": FieldValue.serverTimestamp(),
                "user_id": userId
            ]
            
            try await db.collection(leaderboardCollection).addDocument(data: entry)
        }
    }
    
    func fetchLeaderboard(limit: Int = 100, level: String? = nil) async throws -> [LeaderboardEntry] {
        isLoading = true
        defer { isLoading = false }
        
        var query: Query = db.collection(leaderboardCollection)
            .order(by: "score", descending: true)
            .limit(to: limit)
        
        // Filter by level if specified (optional - shows last played level)
        if let level = level {
            query = query.whereField("level", isEqualTo: level)
        }
        
        do {
            let snapshot = try await query.getDocuments()
            let entries = snapshot.documents.compactMap { document -> LeaderboardEntry? in
                try? document.data(as: LeaderboardEntry.self)
            }
            
            await MainActor.run {
                self.leaderboard = entries
            }
            
            return entries
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
            throw error
        }
    }
    
    func getTopScores(limit: Int = 10) async throws -> [LeaderboardEntry] {
        return try await fetchLeaderboard(limit: limit)
    }
    
    func getPlayerRank(userId: String) async throws -> Int? {
        let leaderboard = try await fetchLeaderboard(limit: 1000)
        
        // Find the player's rank
        if let rank = leaderboard.firstIndex(where: { $0.userId == userId }) {
            return rank + 1
        }
        
        return nil
    }
    
    // MARK: - Real-time Listener
    
    func listenToLeaderboard(limit: Int = 100, level: String? = nil) {
        var query: Query = db.collection(leaderboardCollection)
            .order(by: "score", descending: true)
            .limit(to: limit)
        
        if let level = level {
            query = query.whereField("level", isEqualTo: level)
        }
        
        query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                Task { @MainActor in
                    self.error = error.localizedDescription
                }
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            let entries = documents.compactMap { document -> LeaderboardEntry? in
                try? document.data(as: LeaderboardEntry.self)
            }
            
            Task { @MainActor in
                self.leaderboard = entries
            }
        }
    }
}
