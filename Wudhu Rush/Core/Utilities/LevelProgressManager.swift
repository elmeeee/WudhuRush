
import SwiftUI
import Combine

class LevelProgressManager: ObservableObject {
    static let shared = LevelProgressManager()
    
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
        return index > highestUnlockedIndex
    }
    
    func resetProgress() {
        highestUnlockedIndex = 0
    }
}
