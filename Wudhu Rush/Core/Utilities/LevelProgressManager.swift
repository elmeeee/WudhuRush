//
//  LevelProgressManager.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI
import Combine

class LevelProgressManager: ObservableObject {
    static let shared = LevelProgressManager()
    
    // ⚙️ DEBUG FLAG - Set to true to unlock ALL levels for testing
    // Set back to false before release!
    static let DEBUG_UNLOCK_ALL_LEVELS = false
    
    @Published var highestUnlockedIndex: Int {
        didSet {
            UserDefaults.standard.set(highestUnlockedIndex, forKey: "highestUnlockedIndex")
        }
    }
    
    private init() {
        self.highestUnlockedIndex = UserDefaults.standard.integer(forKey: "highestUnlockedIndex")
    }
    
    func unlockLevel(at index: Int) {
        if index > highestUnlockedIndex {
            highestUnlockedIndex = index
        }
    }
    
    func isLocked(index: Int) -> Bool {
        // If debug flag is on, nothing is locked
        if Self.DEBUG_UNLOCK_ALL_LEVELS {
            return false
        }
        return index > highestUnlockedIndex
    }
    
    func resetProgress() {
        highestUnlockedIndex = 0
    }
}
