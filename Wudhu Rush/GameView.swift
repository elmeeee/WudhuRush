
import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject private var engine = GameEngine()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            GameTheme.background
                .ignoresSafeArea()
            GeometryReader { proxy in
                SpriteView(scene: setupScene(size: proxy.size))
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .ignoresSafeArea()
            VStack {
                HStack {
                    Button(action: {
                        engine.stopGame()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(GameTheme.primaryGreen)
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Time Attack")
                        .font(.headline)
                        .foregroundColor(GameTheme.primaryGreen)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                        Text("\(Int(engine.timeRemaining))")
                            .monospacedDigit()
                    }
                    .font(.headline)
                    .foregroundColor(engine.timeRemaining < 10 ? GameTheme.errorRed : GameTheme.primaryGreen)
                    .padding(10)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                }
                .padding(.horizontal)
                .padding(.top, 50)
                
                Text("Score: \(engine.score)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(GameTheme.primaryGreen.opacity(0.8))
                    .padding(.top, 4)
                
                Spacer()
            }
            if engine.gameState == .finished {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                ResultView(score: engine.score, mistakes: engine.mistakes, onRestart: {
                    withAnimation {
                        engine.startGame()
                    }
                }, onHome: {
                    presentationMode.wrappedValue.dismiss()
                })
                .transition(.scale)
                .zIndex(100)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            engine.startGame()
        }
    }
    
    private func setupScene(size: CGSize) -> SKScene {
        let scene = GameScene()
        scene.size = size
        scene.scaleMode = .aspectFill
        scene.gameEngine = engine
        return scene
    }
}
