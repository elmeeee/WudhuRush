
import Foundation
import SwiftUI
import Combine

enum GameMode: Hashable {
    case level(LevelData)
    case practice // Endless/Practice
}

enum GameState {
    case playing
    case finished
}

class GameEngine: ObservableObject {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 60.0
    @Published var mistakes: Int = 0
    @Published var gameState: GameState = .playing
    @Published var filledSlots: [Int: WudhuStepModel] = [:] 
    
    // Loaded Content
    @Published var currentLevelSteps: [WudhuStepModel] = []
    @Published var activeCards: [WudhuStepModel] = [] // Steps + Distractors
    @Published var targetSlotCount: Int = 0
    
    // Feedback
    @Published var lastCorrectStep: WudhuStepModel?
    @Published var showFeedback: Bool = false
    
    var gameMode: GameMode
    var levelData: LevelData?
    
    private var timer: Timer?
    
    // Mock Leaderboard
    @Published var leaderboard: [(name: String, score: Int)] = [
        ("Ali", 1200), ("Fatima", 1150), ("Omar", 980)
    ]
    
    init(mode: GameMode) {
        self.gameMode = mode
        setupGame()
    }
    
    private func setupGame() {
        switch gameMode {
        case .level(let data):
            self.levelData = data
            self.timeRemaining = TimeInterval(data.time_limit)
            
            // Parse Steps
            var allCards: [WudhuStepModel] = []
            var correctSteps: [WudhuStepModel] = []
            
            // Correct Steps
            for (index, title) in data.steps.enumerated() {
                let step = WudhuStepModel(title: title, order: index + 1, isDistractor: false)
                correctSteps.append(step)
                allCards.append(step)
            }
            
            // Distractors
            for title in data.distractors {
                let step = WudhuStepModel(title: title, order: -1, isDistractor: true)
                allCards.append(step)
            }
            
            self.currentLevelSteps = correctSteps
            self.activeCards = allCards.shuffled()
            self.targetSlotCount = correctSteps.count
            
        case .practice:
             // Load Level 1 as base for practice but no timer
            if let content = LocalizationManager.shared.content, let firstLevel = content.levels.first {
                self.levelData = firstLevel
                self.timeRemaining = 0
                
                var steps: [WudhuStepModel] = []
                for (index, title) in firstLevel.steps.enumerated() {
                    steps.append(WudhuStepModel(title: title, order: index + 1, isDistractor: false))
                }
                self.currentLevelSteps = steps
                self.activeCards = steps.shuffled() // No distractors in basic practice for now? Or keep simple
                self.targetSlotCount = steps.count
            }
        }
    }
    
    func startGame() {
        resetGame()
        if case .level = gameMode {
            startTimer()
        }
    }
    
    func resetGame() {
        score = 0
        mistakes = 0
        gameState = .playing
        filledSlots = [:]
        lastCorrectStep = nil
        showFeedback = false
        
        setupGame() // Re-shuffle and reset time
    }
    
    func stopGame() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startTimer() {
        stopGame()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.finishGame()
                }
            }
        }
    }
    
    func finishGame() {
        stopGame()
        gameState = .finished
        
        // Save score if needed
    }
    
    func validateDrop(step: WudhuStepModel, atSlotIndex index: Int) -> Bool {
        // Slot Index is 0-based, Step Order is 1-based
        let correctIndex = step.order - 1
        
        // Logic:
        // 1. Must not be a distractor (order > 0)
        // 2. Must match the slot index
        
        if !step.isDistractor && correctIndex == index {
            calculateScore(success: true)
            filledSlots[index] = step
            
            // Feedback
            if case .practice = gameMode {
                DispatchQueue.main.async {
                    self.lastCorrectStep = step
                    self.showFeedback = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if self.lastCorrectStep == step { self.showFeedback = false }
                    }
                }
            }
            
            if filledSlots.count == targetSlotCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.finishGame()
                }
            }
            return true
        } else {
            calculateScore(success: false)
            mistakes += 1
            
            // Sudden death rule check?
             if let rule = levelData?.rule, rule == "Sudden Death" {
                 // Immediate Fail
                 // For now just finish game? Or specific fail state? 
                 // Simple finish for MVP
                 finishGame()
             }
            
            return false
        }
    }
    
    private func calculateScore(success: Bool) {
        if success {
            var points = 100
            
            // Time bonus
            if case .level = gameMode {
                points += Int(timeRemaining)
            }
            score += points
        } else {
            score = max(0, score - 20)
        }
    }
}
