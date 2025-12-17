
import Foundation

struct WudhuStepModel: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let order: Int // 1-based index. If 0 or -1, it's a distractor
    let isDistractor: Bool
    
    // Icon name helper (can map from title or be generic)
    var iconName: String {
        // Simple mapping based on keywords if needed, or generic
        return "hand.tap" 
    }
}
