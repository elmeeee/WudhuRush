//
//  GameView.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject private var engine: GameEngine
    @Environment(\.dismiss) var dismiss
    @ObservedObject var localization = LocalizationManager.shared
    @State private var scene: GameScene?
    @State private var highlightedSlot: Int? = nil
    @State private var navigationPath: [NavigationDestination] = []
    
    init(mode: GameMode) {
        _engine = StateObject(wrappedValue: GameEngine(mode: mode))
    }
    
    private func getNextLevel() -> LevelData? {
        guard case .level(let currentLevel) = engine.gameMode,
              let allLevels = LocalizationManager.shared.content?.levels,
              let currentIndex = allLevels.firstIndex(where: { $0.id == currentLevel.id }),
              currentIndex + 1 < allLevels.count else {
            return nil
        }
        return allLevels[currentIndex + 1]
    }
    
    
    var body: some View {
        ZStack {
            GameTheme.background
                .ignoresSafeArea()
            
            if engine.isVoiceChallenge {
                VoiceChallengeView(engine: engine)
            } else {
                GeometryReader { proxy in
                    if let scene = scene {
                        SpriteView(scene: scene, options: [.allowsTransparency])
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .focusable(false)
                            .focusEffectDisabled(true)
                    } else {
                        Color.clear
                            .onAppear {
                                let newScene = GameScene()
                                newScene.size = proxy.size
                                newScene.scaleMode = .aspectFill
                                newScene.gameEngine = engine
                                self.scene = newScene
                            }
                    }
                }
                .ignoresSafeArea()
                .focusable(false)
            }
            
            VStack {
                if !engine.isVoiceChallenge {
                    HStack(alignment: .center) {
                        Button(action: {
                            engine.stopGame()
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(GameTheme.textDark)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            if case .level(let level) = engine.gameMode {
                                Text(localization.ui(\UIData.time_attack).uppercased())
                                    .font(.caption2)
                                    .fontWeight(.black)
                                    .foregroundColor(GameTheme.primaryGreen.opacity(0.6))
                                Text(level.internal_name)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(GameTheme.primaryGreen)
                            } else {
                                Text(localization.ui(\UIData.practice).uppercased())
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(GameTheme.primaryGreen)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(20)
                        .shadow(radius: 2)
                            
                        Spacer().allowsHitTesting(false)
                        
                        if engine.maxHints > 0 {
                            Button(action: {
                                if let hint = engine.useHint() {
                                    highlightedSlot = hint.slotIndex
                                    scene?.highlightSlot(at: hint.slotIndex)
                                    scene?.highlightCard(step: hint.correctStep)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        highlightedSlot = nil
                                    }
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "lightbulb.fill")
                                    Text("\(engine.hintsRemaining)")
                                        .monospacedDigit()
                                }
                                .font(.headline)
                                .foregroundColor(engine.hintsRemaining > 0 ? GameTheme.gold : GameTheme.textLight)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 2)
                            }
                            .disabled(engine.hintsRemaining == 0)
                        }
                        
                        
                        if case .level = engine.gameMode {
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                Text("\(Int(engine.timeRemaining))")
                                    .monospacedDigit()
                            }
                            .font(.headline)
                            .foregroundColor(getTimeColor())
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 2)
                            
                            Button(action: {
                                withAnimation {
                                    engine.shuffleVisibleCards()
                                    scene?.forceLayoutUpdate()
                                }
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(GameTheme.primaryGreen)
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    HStack {
                        Button(action: {
                            engine.stopGame()
                            engine.speechRecognizer?.stopRecording()
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(GameTheme.textDark)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                if case .level = engine.gameMode, !engine.isVoiceChallenge {
                    Text("Score: \(engine.score)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(GameTheme.textDark)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .padding(.top, 4)
                } else {
                    Text("\(engine.filledSlots.count)/\(engine.targetSlotCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(GameTheme.textDark)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .padding(.top, 4)
                }
                
                Spacer().allowsHitTesting(false)
                
                if let step = engine.lastCorrectStep, engine.showFeedback {
                    HStack(spacing: 16) {
                        Image(systemName: "info.circle.fill")
                            .font(.title)
                            .foregroundColor(GameTheme.gold)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.title)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(localization.feedback(\FeedbackData.correct))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(GameTheme.darkGreen.opacity(0.95))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(), value: engine.showFeedback)
                }
            }
            
            if case .finished = engine.gameState {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                ResultView(
                    score: engine.score,
                    mistakes: engine.mistakes,
                    mode: engine.gameMode,
                    engine: engine,
                    onRestart: {
                        withAnimation { 
                            engine.startGame()
                            scene?.resetForNewLevel()
                        }
                    },
                    onHome: {
                        dismiss()
                    },
                    onNextLevel: getNextLevel() != nil ? {
                        if let nextLevel = getNextLevel() {
                            if let allLevels = LocalizationManager.shared.content?.levels,
                               let nextIndex = allLevels.firstIndex(where: { $0.id == nextLevel.id }) {
                                LevelProgressManager.shared.unlockLevel(at: nextIndex)
                            }
                            
                            withAnimation {
                                engine.loadNextLevel(nextLevel)
                                engine.startGame()
                                scene?.resetForNewLevel()
                            }
                        }
                    } : nil
                )
                .transition(.scale(scale: 0.8).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            engine.startGame()
        }
    }
    
    private func getTimeColor() -> Color {
        if engine.timeRemaining < 10 { return GameTheme.error }
        if engine.timeRemaining < 30 { return GameTheme.gold }
        return GameTheme.primaryGreen
    }
}
