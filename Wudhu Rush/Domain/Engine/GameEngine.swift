//
//  GameEngine.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

enum GameMode: Hashable {
    case level(LevelData)
    case practice
}

enum GameState {
    case playing
    case finished(GameResult)
}

enum GameResult {
    case win
    case loss
}

class GameEngine: ObservableObject {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 60.0
    @Published var mistakes: Int = 0
    @Published var gameState: GameState = .playing
    @Published var filledSlots: [Int: WudhuStepModel] = [:]
    @Published var currentLevelSteps: [WudhuStepModel] = []
    @Published var activeCards: [WudhuStepModel] = []
    @Published var targetSlotCount: Int = 0
    @Published var lastCorrectStep: WudhuStepModel?
    @Published var showFeedback: Bool = false
    @Published var showIncorrectFeedback: Bool = false
    @Published var hintsRemaining: Int = 0
    @Published var maxHints: Int = 0
    
    // Card pool system - only show 4 cards at a time
    private var availableCardPool: [WudhuStepModel] = []
    private let maxVisibleCards = 4
    
    // Voice Challenge properties
    @Published var currentStepIndex: Int = 0
    @Published var isVoiceChallenge: Bool = false
    var speechRecognizer: SpeechRecognitionManager?
    
    var gameMode: GameMode
    var levelData: LevelData?
    
    private var timer: Timer?
    
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
            
            // Check if voice challenge
            isVoiceChallenge = data.game_type == "voice_challenge"
            if isVoiceChallenge {
                speechRecognizer = SpeechRecognitionManager()
                currentStepIndex = 0
                maxHints = 0
                hintsRemaining = 0
            } else {
                // Set hints based on level for drag & drop
                switch data.id {
                case "L01", "L02", "L03", "L04", "L05", "L06", "L07":
                    maxHints = 3
                case "L08", "L09":
                    maxHints = 1
                case "L10":
                    maxHints = 0
                default:
                    maxHints = 3
                }
                hintsRemaining = maxHints
            }
            
            var allCards: [WudhuStepModel] = []
            var correctSteps: [WudhuStepModel] = []
            for (index, title) in data.steps.enumerated() {
                let step = WudhuStepModel(title: title, order: index + 1, isDistractor: false)
                correctSteps.append(step)
                allCards.append(step)
            }
            
            for title in data.distractors {
                let step = WudhuStepModel(title: title, order: -1, isDistractor: true)
                allCards.append(step)
            }
            
            self.currentLevelSteps = correctSteps
            
            // Initialize card pool system
            let shuffledCards = allCards.shuffled()
            self.availableCardPool = shuffledCards
            
            // Show only first 4 cards (or less if total cards < 4)
            let cardsToShow = min(maxVisibleCards, shuffledCards.count)
            self.activeCards = Array(shuffledCards.prefix(cardsToShow))
            
            // Remove shown cards from pool
            self.availableCardPool.removeFirst(cardsToShow)
            
            self.targetSlotCount = correctSteps.count
            
        case .practice:
            // Practice mode: unlimited hints (for drag&drop), no hints for voice
            maxHints = isVoiceChallenge ? 0 : 999
            hintsRemaining = maxHints
            
            if isVoiceChallenge {
                speechRecognizer = SpeechRecognitionManager()
                currentStepIndex = 0
            }
            
            if let content = LocalizationManager.shared.content, let firstLevel = content.levels.first {
                self.levelData = firstLevel
                self.timeRemaining = 0
                
                var steps: [WudhuStepModel] = []
                for (index, title) in firstLevel.steps.enumerated() {
                    steps.append(WudhuStepModel(title: title, order: index + 1, isDistractor: false))
                }
                self.currentLevelSteps = steps
                
                // Use card pool for practice mode too
                let shuffledSteps = steps.shuffled()
                self.availableCardPool = shuffledSteps
                let cardsToShow = min(maxVisibleCards, shuffledSteps.count)
                self.activeCards = Array(shuffledSteps.prefix(cardsToShow))
                self.availableCardPool.removeFirst(cardsToShow)
                
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
        
        setupGame()
    }
    
    func loadNextLevel(_ level: LevelData) {
        gameMode = .level(level)
        score = 0
        mistakes = 0
        gameState = .playing
        filledSlots = [:]
        lastCorrectStep = nil
        showFeedback = false
        currentStepIndex = 0
        
        setupGame()
    }
    
    
    func useHint() -> (slotIndex: Int, correctStep: WudhuStepModel)? {
        guard hintsRemaining > 0 else { return nil }
        hintsRemaining -= 1
        
        // Find next empty slot
        for i in 0..<targetSlotCount {
            if filledSlots[i] == nil {
                // Find the correct step for this slot
                let correctStep = currentLevelSteps[i]
                return (i, correctStep)
            }
        }
        return nil
    }
    
    func shuffleVisibleCards() {
        // Combine current visible cards with pool
        var allAvailableCards = activeCards + availableCardPool
        
        // Shuffle all available cards
        allAvailableCards.shuffle()
        
        // Take up to 4 cards for display
        let cardsToShow = min(maxVisibleCards, allAvailableCards.count)
        activeCards = Array(allAvailableCards.prefix(cardsToShow))
        
        // Rest goes back to pool
        availableCardPool = Array(allAvailableCards.dropFirst(cardsToShow))
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
        
        let isWin: Bool
        if isVoiceChallenge {
            isWin = currentStepIndex >= targetSlotCount
        } else {
            isWin = filledSlots.count == targetSlotCount
        }
        
        if isWin, case .level(let levelData) = gameMode {
             if let allLevels = LocalizationManager.shared.content?.levels,
                let currentIndex = allLevels.firstIndex(where: { $0.id == levelData.id }) {
                 LevelProgressManager.shared.unlockLevel(at: currentIndex + 1)
             }
        }
        
        gameState = .finished(isWin ? .win : .loss)
    }
    
    func validateDrop(step: WudhuStepModel, atSlotIndex index: Int) -> Bool {
        let correctIndex = step.order - 1
        
        if !step.isDistractor && correctIndex == index {
            calculateScore(success: true)
            filledSlots[index] = step
            
            // Remove the used card from activeCards
            if let cardIndex = activeCards.firstIndex(where: { $0.title == step.title && $0.order == step.order }) {
                activeCards.remove(at: cardIndex)
                
                // Add a new card from the pool if available
                if !availableCardPool.isEmpty {
                    let newCard = availableCardPool.removeFirst()
                    activeCards.append(newCard)
                }
            }

            if case .practice = gameMode, !isVoiceChallenge {
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
            
            // Show incorrect feedback
            showIncorrectFeedback = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showIncorrectFeedback = false
            }
            
             if let rule = levelData?.rule, rule == "Sudden Death" {
                 finishGame()
             }
            
            return false
        }
    }
    
    private func calculateScore(success: Bool) {
        if success {
            var points = 100
            
            if case .level = gameMode {
                points += Int(timeRemaining)
            }
            score += points
        } else {
            score = max(0, score - 20)
        }
    }
    
    // MARK: - Voice Challenge Methods
    
    func validateVoiceInput() -> Bool {
        guard isVoiceChallenge,
              let recognizer = speechRecognizer else {
            return false
        }
        
        // Get expected Arabic text
        let arabicSteps: [String]?
        if case .practice = gameMode {
            arabicSteps = LocalizationManager.shared.content?.endless_mode.arabic_steps
        } else {
            arabicSteps = levelData?.arabic_steps
        }
        
        guard let steps = arabicSteps,
              currentStepIndex < steps.count else {
            return false
        }
        
        let expectedText = steps[currentStepIndex]
        let isCorrect = recognizer.matchesExpectedText(expectedText, tolerance: 0.7)
        
        if isCorrect {
            calculateScore(success: true)
            currentStepIndex += 1
            
            // Check if all steps completed
            if currentStepIndex >= targetSlotCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.finishGame()
                }
            }
        } else {
            calculateScore(success: false)
            mistakes += 1
        }
        
        return isCorrect
    }
    
    func getCurrentArabicText() -> String? {
        guard isVoiceChallenge else { return nil }
        
        // For practice mode with voice, use endless_mode data
        if case .practice = gameMode {
            guard let content = LocalizationManager.shared.content,
                  let arabicSteps = content.endless_mode.arabic_steps,
                  currentStepIndex < arabicSteps.count else {
                return nil
            }
            return arabicSteps[currentStepIndex]
        }
        
        // For level voice mode, use level data
        guard let levelData = levelData,
              let arabicSteps = levelData.arabic_steps,
              currentStepIndex < arabicSteps.count else {
            return nil
        }
        return arabicSteps[currentStepIndex]
    }
    
    func getCurrentRomanization() -> String? {
        guard isVoiceChallenge else { return nil }
        
        // For practice mode with voice, use endless_mode data
        if case .practice = gameMode {
            guard let content = LocalizationManager.shared.content,
                  let romanization = content.endless_mode.romanization,
                  currentStepIndex < romanization.count else {
                return nil
            }
            return romanization[currentStepIndex]
        }
        
        // For level voice mode, use level data
        guard let levelData = levelData,
              let romanization = levelData.romanization,
              currentStepIndex < romanization.count else {
            return nil
        }
        return romanization[currentStepIndex]
    }
}
