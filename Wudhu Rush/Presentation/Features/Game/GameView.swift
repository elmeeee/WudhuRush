
import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject private var engine: GameEngine
    @Environment(\.dismiss) var dismiss
    @ObservedObject var localization = LocalizationManager.shared
    
    // Cache the scene to prevent recreation during view updates
    @State private var scene: GameScene?
    
    init(mode: GameMode) {
        _engine = StateObject(wrappedValue: GameEngine(mode: mode))
    }
    
    var body: some View {
        ZStack {
            GameTheme.background
                .ignoresSafeArea()
            
            // SpriteKit Layer
            // We use GeometryReader to get the size, but we only create the scene ONCE.
            GeometryReader { proxy in
                if let scene = scene {
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .focusable(false) // Disable focus engine for this view
                        .focusEffectDisabled(true) // Disable focus effects
                } else {
                    Color.clear
                        .onAppear {
                            // Initialize scene once we know the size
                            let newScene = GameScene() // We'll set size immediately
                            newScene.size = proxy.size
                            newScene.scaleMode = .aspectFill
                            newScene.gameEngine = engine
                            self.scene = newScene
                        }
                }
            }
            .ignoresSafeArea()
            .focusable(false) // Ensure container is also not focusable
            
            // HUD Layer
            VStack {
                // Header
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
                    
                    // Title
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
                    
                    // Timer / Reset
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
                    } else {
                        Button(action: {
                            // Reset scene logic safely
                            withAnimation { engine.resetGame() }
                            // Force scene refresh if needed, but Engine binding should handle it
                            scene?.forceLayoutUpdate()
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
                .padding(.top, 50)
                
                // Score / Progress
                if case .level = engine.gameMode {
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
                
                // Feedback Toast
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
                    .padding(.bottom, 150)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(), value: engine.showFeedback)
                }
            }
            
            // Result Overlay
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
                            scene?.forceLayoutUpdate()
                        }
                    },
                    onHome: {
                        dismiss()
                    }
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
