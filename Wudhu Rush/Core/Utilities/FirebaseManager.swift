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
    let level: String
    let timestamp: Date
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case playerName = "player_name"
        case score
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
        
        let entry = LeaderboardEntry(
            playerName: playerName,
            score: score,
            level: level,
            timestamp: Date(),
            userId: userId
        )
        
        do {
            _ = try db.collection(leaderboardCollection).addDocument(from: entry)
            print("Score submitted successfully")
        } catch {
            print("Error submitting score: \(error)")
            throw error
        }
    }
    
    // MARK: - Fetch Leaderboard
    
    func fetchLeaderboard(limit: Int = 100, level: String? = nil) async throws -> [LeaderboardEntry] {
        isLoading = true
        defer { isLoading = false }
        
        var query: Query = db.collection(leaderboardCollection)
            .order(by: "score", descending: true)
        
        // Filter by level if specified
        if let level = level {
            query = query.whereField("level", isEqualTo: level)
        }
        
        query = query.limit(to: limit)
        
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
        let allScores = try await fetchLeaderboard(limit: 1000)
        
        // Find player's best score
        let playerScores = allScores.filter { $0.userId == userId }
        guard let bestScore = playerScores.max(by: { $0.score < $1.score }) else {
            return nil
        }
        
        // Find rank
        if let rank = allScores.firstIndex(where: { $0.id == bestScore.id }) {
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
