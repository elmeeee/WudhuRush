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
            self.activeCards = allCards.shuffled()
            self.targetSlotCount = correctSteps.count
            
        case .practice:
            if let content = LocalizationManager.shared.content, let firstLevel = content.levels.first {
                self.levelData = firstLevel
                self.timeRemaining = 0
                
                var steps: [WudhuStepModel] = []
                for (index, title) in firstLevel.steps.enumerated() {
                    steps.append(WudhuStepModel(title: title, order: index + 1, isDistractor: false))
                }
                self.currentLevelSteps = steps
                self.activeCards = steps.shuffled()
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
        if case .level = gameMode {
            isWin = filledSlots.count == targetSlotCount
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
}
