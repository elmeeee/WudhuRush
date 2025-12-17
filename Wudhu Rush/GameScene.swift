
import SpriteKit
import UIKit // Ensure UITouch and UIEvent are available

class CardNode: SKNode {
    let step: WudhuStepModel
    private let background: HFShapeNode // Helper rounded rect
    private let label: SKLabelNode
    
    init(step: WudhuStepModel, size: CGSize) {
        self.step = step
        self.background = HFShapeNode(rectOf: size, cornerRadius: 12)
        self.label = SKLabelNode(fontNamed: "System-Bold")
        
        super.init()
        
        // Card Appearance
        background.fillColor = GameTheme.skCardWhite
        background.strokeColor = GameTheme.skSoftGreen
        background.lineWidth = 2
        
        // Shadows/Depth (simulated)
        let shadow = SKShapeNode(rectOf: size, cornerRadius: 12)
        shadow.fillColor = .black
        shadow.alpha = 0.1
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        addChild(shadow)
        
        addChild(background)
        
        // Text
        label.text = step.title
        label.fontSize = 18
        label.fontColor = GameTheme.skTextDark
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        addChild(label)
        
        self.name = "card-\(step.order)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHighlight(_ highlight: Bool) {
        if highlight {
            background.strokeColor = GameTheme.skGoldAccent
            background.lineWidth = 4
            self.setScale(1.1)
        } else {
            background.strokeColor = GameTheme.skSoftGreen
            background.lineWidth = 2
            self.setScale(1.0)
        }
    }
}

// Helper for SKShapeNode to avoid annoying warnings or issues with path
class HFShapeNode: SKShapeNode {}

class GameScene: SKScene {
    
    var gameEngine: GameEngine?
    
    private var slots: [SKShapeNode] = []
    private var cards: [CardNode] = []
    
    private var draggingCard: CardNode?
    private var touchOffset: CGPoint = .zero
    private var originalPosition: CGPoint = .zero
    
    private let slotSize = CGSize(width: 280, height: 60)
    
    override func didMove(to view: SKView) {
        backgroundColor = GameTheme.skBackground
        setupLayout()
    }
    
    private func setupLayout() {
        removeAllChildren()
        slots.removeAll()
        cards.removeAll()
        
        guard gameEngine != nil else { return }
        
        _ = view?.safeAreaInsets.top ?? 20
        let _ = view?.safeAreaInsets.bottom ?? 20
        
        // Setup 6 Slots (Vertically Stacked)
        let startY = size.height / 2 + 150
        let spacing: CGFloat = 80
        
        for i in 0..<WudhuStepModel.allSteps.count {
            let slot = SKShapeNode(rectOf: slotSize, cornerRadius: 12)
            slot.fillColor = GameTheme.skSoftGreen.withAlphaComponent(0.3)
            slot.strokeColor = GameTheme.skPrimaryGreen
            slot.lineWidth = 2
            // Dashed line simulation by using strict color or texture?
            // SpriteKit dashed lines are complex, keep simple for now.
            slot.userData = ["index": i]
            
            let yPos = startY - (CGFloat(i) * spacing)
            slot.position = CGPoint(x: size.width / 2, y: yPos)
            addChild(slot)
            slots.append(slot)
            
            // Number label
            let numLabel = SKLabelNode(fontNamed: "System-Bold")
            numLabel.text = "\(i + 1)"
            numLabel.fontSize = 24
            numLabel.fontColor = GameTheme.skPrimaryGreen.withAlphaComponent(0.5)
            numLabel.position = CGPoint(x: -slotSize.width/2 - 30, y: -10)
            slot.addChild(numLabel)
        }
        
        // Setup Cards at Bottom (Random Order)
        setupCards(steps: WudhuStepModel.allSteps.shuffled())
    }
    
    private func setupCards(steps: [WudhuStepModel]) {
        let bottomAreaY = size.height * 0.15
        let cardStartX = size.width / 2
        
        // Stack them or layout?
        // Since there are 6 cards, maybe 2 rows of 3? or scroll?
        // Let's do 2 columns of 3 rows at the bottom?
        
        // Let's try to fit them in the bottom area.
        let colSpacing: CGFloat = 160
        let rowSpacing: CGFloat = 70
        
        for (i, step) in steps.enumerated() {
            let card = CardNode(step: step, size: CGSize(width: 140, height: 50))
            
            let col = i % 2
            let row = i / 2
            
            let xPos = cardStartX + (CGFloat(col == 0 ? -1 : 1) * (colSpacing / 2))
            let yPos = bottomAreaY + (CGFloat(row) * rowSpacing) - 80
            
            card.position = CGPoint(x: xPos, y: yPos)
            card.zPosition = 10
            addChild(card)
            cards.append(card)
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Find card
        let nodes = nodes(at: location)
        for node in nodes {
            if let card = node as? CardNode ?? node.parent as? CardNode {
                // If card is already placed correctly, maybe don't move it?
                // For now allow moving until locked?
                // Let's assume once placed correctly it's locked?
                // Engine handles state.
                
                draggingCard = card
                originalPosition = card.position
                touchOffset = CGPoint(x: location.x - card.position.x, y: location.y - card.position.y)
                
                card.setHighlight(true)
                card.zPosition = 100 // Bring to front
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let card = draggingCard else { return }
        let location = touch.location(in: self)
        card.position = CGPoint(x: location.x - touchOffset.x, y: location.y - touchOffset.y)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let card = draggingCard else { return }
        
        // Check drop
        var dropped = false
        
        for slot in slots {
            if slot.contains(card.position) {
                if let index = slot.userData?["index"] as? Int {
                    if gameEngine?.validateDrop(step: card.step, atSlotIndex: index) == true {
                        // Success Drop
                        dropped = true
                        
                        // Snap to slot
                        let move = SKAction.move(to: slot.position, duration: 0.2)
                        move.timingMode = .easeOut
                        card.run(move)
                        
                        // Disable interaction
                        card.isUserInteractionEnabled = false // Actually we handle it via touchesBegan check ideally
                        // Remove from tracking or lock it
                        
                        // Feedback
                        let sequence = SKAction.sequence([
                            SKAction.scale(to: 1.2, duration: 0.1),
                            SKAction.scale(to: 1.0, duration: 0.1)
                        ])
                        card.run(sequence)
                        
                        // Play sound?
                        run(SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false)) // Placeholder
                    }
                }
            }
        }
        
        if !dropped {
            // Return to original
            let move = SKAction.move(to: originalPosition, duration: 0.3)
            move.timingMode = .easeOut
            card.run(move)
            
            // Error shake
            let shakeLeft = SKAction.moveBy(x: -5, y: 0, duration: 0.05)
            let shakeRight = SKAction.moveBy(x: 5, y: 0, duration: 0.05)
            card.run(SKAction.sequence([shakeLeft, shakeRight, shakeLeft, shakeRight]))
        }
        
        card.setHighlight(false)
        card.zPosition = 10
        draggingCard = nil
    }
}
