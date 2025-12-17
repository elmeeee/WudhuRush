//
//  UserProfileManager.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

struct UserProfile: Codable {
    let userId: String
    var playerName: String
    var totalScore: Int
    var gamesPlayed: Int
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case playerName = "player_name"
        case totalScore = "total_score"
        case gamesPlayed = "games_played"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

@MainActor
final class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()
    
    @Published var currentUser: User?
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var hasSetName: Bool = false
    
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    var playerName: String {
        userProfile?.playerName ?? ""
    }
    
    var userId: String {
        currentUser?.uid ?? ""
    }
    
    private init() {
        // Listen to auth state changes
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                self?.currentUser = user
                if let user = user {
                    await self?.loadUserProfile(userId: user.uid)
                }
            }
        }
    }
    
    deinit {
        if let handle = authStateListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Authentication
    
    func signInAnonymously() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().signInAnonymously()
            currentUser = result.user
            print("✅ Signed in anonymously: \(result.user.uid)")
        } catch {
            print("❌ Error signing in anonymously: \(error)")
            throw error
        }
    }
    
    // MARK: - Profile Management
    
    func setPlayerName(_ name: String) async throws {
        guard let userId = currentUser?.uid else {
            throw NSError(domain: "UserProfile", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw NSError(domain: "UserProfile", code: -2, userInfo: [NSLocalizedDescriptionKey: "Name cannot be empty"])
        }
        
        // Check if profile exists
        let docRef = db.collection(usersCollection).document(userId)
        let document = try await docRef.getDocument()
        
        if document.exists {
            // Update existing profile
            try await docRef.updateData([
                "player_name": trimmedName,
                "updated_at": FieldValue.serverTimestamp()
            ])
        } else {
            // Create new profile
            let newProfile = UserProfile(
                userId: userId,
                playerName: trimmedName,
                totalScore: 0,
                gamesPlayed: 0,
                createdAt: Date(),
                updatedAt: Date()
            )
            try docRef.setData(from: newProfile)
        }
        
        hasSetName = true
        await loadUserProfile(userId: userId)
    }
    
    func loadUserProfile(userId: String) async {
        do {
            let docRef = db.collection(usersCollection).document(userId)
            let document = try await docRef.getDocument()
            
            if let profile = try? document.data(as: UserProfile.self) {
                self.userProfile = profile
                self.hasSetName = !profile.playerName.isEmpty
            } else {
                self.hasSetName = false
            }
        } catch {
            print("❌ Error loading user profile: \(error)")
        }
    }
    
    func updateStats(scoreToAdd: Int) async throws {
        guard let userId = currentUser?.uid else { return }
        
        let docRef = db.collection(usersCollection).document(userId)
        
        try await docRef.updateData([
            "total_score": FieldValue.increment(Int64(scoreToAdd)),
            "games_played": FieldValue.increment(Int64(1)),
            "updated_at": FieldValue.serverTimestamp()
        ])
        
        await loadUserProfile(userId: userId)
    }
    
    // MARK: - Sign Out
    
    func signOut() throws {
        try Auth.auth().signOut()
        currentUser = nil
        userProfile = nil
        hasSetName = false
    }
}

