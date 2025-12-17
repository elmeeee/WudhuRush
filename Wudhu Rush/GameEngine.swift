
import Foundation
import SwiftUI
import SpriteKit
internal import Combine

// MARK: - Game Theme
struct GameTheme {
    static let primaryGreen = Color(hex: "1E6F5C")
    static let softGreen = Color(hex: "E6F2EE")
    static let background = Color(hex: "F9FAF9")
    static let cardWhite = Color(hex: "FFFFFF")
    static let goldAccent = Color(hex: "D4AF37")
    static let errorRed = Color(hex: "D9534F")
    
    // SpriteKit Colors
    static let skPrimaryGreen = SKColor(red: 0x1E/255.0, green: 0x6F/255.0, blue: 0x5C/255.0, alpha: 1.0)
    static let skSoftGreen = SKColor(red: 0xE6/255.0, green: 0xF2/255.0, blue: 0xEE/255.0, alpha: 1.0)
    static let skBackground = SKColor(red: 0xF9/255.0, green: 0xFA/255.0, blue: 0xF9/255.0, alpha: 1.0)
    static let skCardWhite = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let skGoldAccent = SKColor(red: 0xD4/255.0, green: 0xAF/255.0, blue: 0x37/255.0, alpha: 1.0)
    static let skErrorRed = SKColor(red: 0xD9/255.0, green: 0x53/255.0, blue: 0x4F/255.0, alpha: 1.0)
    static let skTextDark = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            let r = Double((hexNumber & 0xff0000) >> 16) / 255
            let g = Double((hexNumber & 0x00ff00) >> 8) / 255
            let b = Double(hexNumber & 0x0000ff) / 255
            self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
        } else {
            self.init(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
        }
    }
}

// MARK: - Models

struct WudhuStepModel: Identifiable, Equatable {
    let id = UUID()
    let order: Int
    let title: String
    let description: String
    
    static let allSteps: [WudhuStepModel] = [
        WudhuStepModel(order: 1, title: "Niat", description: "Membaca Bismillah & Niat"),
        WudhuStepModel(order: 2, title: "Membasuh Tangan", description: "Cuci telapak tangan"),
        WudhuStepModel(order: 3, title: "Membasuh Muka", description: "Rata dari dahi ke dagu"),
        WudhuStepModel(order: 4, title: "Membasuh Tangan", description: "Sampai siku (Kanan & Kiri)"),
        WudhuStepModel(order: 5, title: "Mengusap Kepala", description: "Sebagian atau seluruhnya"),
        WudhuStepModel(order: 6, title: "Membasuh Kaki", description: "Sampai mata kaki"),
    ]
}

enum GameState {
    case playing
    case finished
}

// MARK: - Game Engine

class GameEngine: ObservableObject {
    var objectWillChange: ObservableObjectPublisher
    
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 60.0
    @Published var mistakes: Int = 0
    @Published var gameState: GameState = .playing
    @Published var filledSlots: [Int: WudhuStepModel] = [:] 
    
    @Published var leaderboard: [(name: String, score: Int)] = [
        ("Ali", 1200),
        ("Fatima", 1150),
        ("Omar", 980)
    ]
    
    private var timer: Timer?
    let maxTime: TimeInterval = 60.0
    
    init() {
        self.objectWillChange = ObservableObjectPublisher()
        resetGame()
    }
    
    func resetGame() {
        score = 0
        timeRemaining = maxTime
        mistakes = 0
        gameState = .playing
        filledSlots = [:]
    }
    
    func startGame() {
        resetGame()
        startTimer()
    }
    
    func stopGame() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startTimer() {
        stopGame()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.finishGame()
            }
        }
    }
    
    func finishGame() {
        stopGame()
        gameState = .finished
        let newScore = score
        leaderboard.append(("You", newScore))
        leaderboard.sort { $0.score > $1.score }
    }
    
    func validateDrop(step: WudhuStepModel, atSlotIndex index: Int) -> Bool {
        let correctIndex = step.order - 1
        
        if correctIndex == index {
            score += 100
            filledSlots[index] = step
            if filledSlots.count == WudhuStepModel.allSteps.count {
                finishGame()
            }
            return true
        } else {
            mistakes += 1
            score = max(0, score - 10)
            return false
        }
    }
    
    var progress: Double {
        return Double(filledSlots.count) / Double(WudhuStepModel.allSteps.count)
    }
}
