
import Foundation

enum GameDifficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    
    var id: String { self.rawValue }
    
    var timeLimit: TimeInterval {
        switch self {
        case .easy: return 90
        case .normal: return 60
        case .hard: return 30
        }
    }
    
    var showSlotNumbers: Bool {
        switch self {
        case .easy: return true
        case .normal: return true // Show numbers to guide
        case .hard: return false // Hide numbers for challenge
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "Relaxed time (90s)"
        case .normal: return "Standard time (60s)"
        case .hard: return "Fast paced (30s) + No Hints"
        }
    }
}
