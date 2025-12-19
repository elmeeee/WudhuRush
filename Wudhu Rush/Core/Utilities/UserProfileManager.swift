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
    
    // UserDefaults keys for persistence
    private let userDefaultsPlayerNameKey = "anonymousPlayerName"
    private let userDefaultsHasSetNameKey = "hasSetAnonymousName"
    private let userDefaultsUserIdKey = "anonymousUserId"
    
    var playerName: String {
        userProfile?.playerName ?? UserDefaults.standard.string(forKey: userDefaultsPlayerNameKey) ?? ""
    }
    
    var userId: String {
        currentUser?.uid ?? ""
    }
    
    private init() {
        // Load persisted data from UserDefaults
        loadPersistedData()
        
        // Listen to auth state changes
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                self?.currentUser = user
                if let user = user {
                    await self?.loadUserProfile(userId: user.uid)
                } else {
                    // User signed out, check if we have persisted anonymous data
                    self?.loadPersistedData()
                }
            }
        }
    }
    
    // MARK: - UserDefaults Persistence
    
    private func loadPersistedData() {
        let savedHasSetName = UserDefaults.standard.bool(forKey: userDefaultsHasSetNameKey)
        let savedPlayerName = UserDefaults.standard.string(forKey: userDefaultsPlayerNameKey)
        
        if savedHasSetName, let name = savedPlayerName, !name.isEmpty {
            hasSetName = true
        } else {
            hasSetName = false
        }
    }
    
    private func saveToUserDefaults(playerName: String, userId: String) {
        UserDefaults.standard.set(playerName, forKey: userDefaultsPlayerNameKey)
        UserDefaults.standard.set(true, forKey: userDefaultsHasSetNameKey)
        UserDefaults.standard.set(userId, forKey: userDefaultsUserIdKey)
        UserDefaults.standard.synchronize()
    }
    
    private func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: userDefaultsPlayerNameKey)
        UserDefaults.standard.removeObject(forKey: userDefaultsHasSetNameKey)
        UserDefaults.standard.removeObject(forKey: userDefaultsUserIdKey)
        UserDefaults.standard.synchronize()
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
        } catch {
            throw error
        }
    }
    
    /// Automatically restore session if user has persisted data but is not signed in
    func restoreSessionIfNeeded() async {
        // If already signed in, no need to restore
        if currentUser != nil {
            return
        }
        
        // Check if we have persisted data
        let savedHasSetName = UserDefaults.standard.bool(forKey: userDefaultsHasSetNameKey)
        let savedPlayerName = UserDefaults.standard.string(forKey: userDefaultsPlayerNameKey)
        
        if savedHasSetName, let name = savedPlayerName, !name.isEmpty {
            print("🔄 Restoring anonymous session for: \(name)")
            do {
                try await signInAnonymously()
            } catch {
                print("Failed to restore session: \(error)")
            }
        }
    }
    
    /// Check if a player name already exists in the database
    func isPlayerNameTaken(_ name: String) async throws -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Query Firestore for existing users with this name (case-insensitive)
        let snapshot = try await db.collection(usersCollection)
            .whereField("player_name_lowercase", isEqualTo: trimmedName)
            .getDocuments()
        
        // If we find any documents, the name is taken
        // But exclude the current user's document if they're updating their name
        if let currentUserId = currentUser?.uid {
            let otherUsers = snapshot.documents.filter { $0.documentID != currentUserId }
            return !otherUsers.isEmpty
        }
        
        return !snapshot.documents.isEmpty
    }
    
    func setPlayerName(_ name: String) async throws {
        guard let userId = currentUser?.uid else {
            throw NSError(domain: "UserProfile", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw NSError(domain: "UserProfile", code: -2, userInfo: [NSLocalizedDescriptionKey: "Name cannot be empty"])
        }
        
        // Check if name is already taken
        let isTaken = try await isPlayerNameTaken(trimmedName)
        if isTaken {
            throw NSError(
                domain: "UserProfile",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "This name is already taken. Please choose a different name."]
            )
        }
        
        // Check if profile exists
        let docRef = db.collection(usersCollection).document(userId)
        let document = try await docRef.getDocument()
        
        let playerNameLowercase = trimmedName.lowercased()
        
        if document.exists {
            // Update existing profile
            try await docRef.updateData([
                "player_name": trimmedName,
                "player_name_lowercase": playerNameLowercase,
                "updated_at": FieldValue.serverTimestamp()
            ])
        } else {
            let profileData: [String: Any] = [
                "user_id": userId,
                "player_name": trimmedName,
                "player_name_lowercase": playerNameLowercase,
                "total_score": 0,
                "games_played": 0,
                "created_at": FieldValue.serverTimestamp(),
                "updated_at": FieldValue.serverTimestamp()
            ]
            
            try await docRef.setData(profileData)
        }
        
        // Save to UserDefaults for persistence
        saveToUserDefaults(playerName: trimmedName, userId: userId)
        
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
                
                // Sync with UserDefaults
                if !profile.playerName.isEmpty {
                    saveToUserDefaults(playerName: profile.playerName, userId: userId)
                }
            } else {
                self.hasSetName = false
            }
        } catch {
            print("Error loading user profile: \(error)")
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
        clearUserDefaults()
    }
}

