
import Swift
import SpriteKit

// MARK: - Components

class CardNode: SKNode {
    let step: WudhuStepModel
    private let background: SKShapeNode
    private let label: SKLabelNode
    
    init(step: WudhuStepModel, size: CGSize) {
        self.step = step
        self.background = SKShapeNode(rectOf: size, cornerRadius: 12)
        self.label = SKLabelNode(fontNamed: "SFProRounded-Bold")
        
        super.init()
        
        // Shadow optimized
        let shadow = SKShapeNode(rectOf: size, cornerRadius: 12)
        shadow.fillColor = .black
        shadow.alpha = 0.15
        shadow.lineWidth = 0
        shadow.position = CGPoint(x: 2, y: -3)
        shadow.zPosition = -1
        addChild(shadow)
        
        // Background
        background.fillColor = GameTheme.skSurface
        background.strokeColor = GameTheme.skLightGreen
        background.lineWidth = 1.5
        addChild(background)
        
        // Text configuration
        label.text = step.title
        label.fontSize = 14
        label.fontColor = GameTheme.skTextDark
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.preferredMaxLayoutWidth = size.width - 16
        label.numberOfLines = 2
        label.position = CGPoint(x: 0, y: -size.height * 0.05)
        label.zPosition = 1
        addChild(label)
        
        // Number Bubble (Cleaner look) 
        // Only show number if not a distractor and order > 0? 
        // The previous design showed numbers on cards. 
        // If it's a distractor, maybe no number or '?'?
        if !step.isDistractor {
            let bubbleRadius: CGFloat = 10
            let numberBubble = SKShapeNode(circleOfRadius: bubbleRadius)
            numberBubble.fillColor = GameTheme.skPrimaryGreen.withAlphaComponent(0.1)
            numberBubble.strokeColor = .clear
            numberBubble.position = CGPoint(x: -size.width/2 + 18, y: size.height/2 - 18)
            addChild(numberBubble)
            
            let numText = SKLabelNode(text: "\(step.order)")
            numText.fontName = "SFProRounded-Bold"
            numText.fontSize = 12
            numText.fontColor = GameTheme.skPrimaryGreen
            numText.verticalAlignmentMode = .center
            numText.position = CGPoint(x: 0, y: 0)
            numberBubble.addChild(numText)
        }
        
        self.name = "card-\(step.id)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHighlight(_ highlight: Bool) {
        removeAllActions()
        if highlight {
            run(SKAction.scale(to: 1.1, duration: 0.05))
            background.strokeColor = GameTheme.skGold
            background.lineWidth = 3
            background.fillColor = SKColor.white
            run(SKAction.rotate(byAngle: CGFloat.random(in: -0.05...0.05), duration: 0.05))
        } else {
            run(SKAction.scale(to: 1.0, duration: 0.05))
            run(SKAction.rotate(toAngle: 0, duration: 0.05))
            background.strokeColor = GameTheme.skLightGreen
            background.lineWidth = 1.5
            background.fillColor = GameTheme.skSurface
        }
    }
}

// MARK: - Scene

class GameScene: SKScene {
    
    func forceLayoutUpdate() {
        setupLayout()
    }
    
    weak var gameEngine: GameEngine? {
        didSet {
             // If engine is set/changed, trigger layout
             if self.scene != nil { setupLayout() }
        }
    }
    
    private var slots: [SKShapeNode] = []
    private var cards: [CardNode] = []
    
    private var draggingCard: CardNode?
    private var touchOffset: CGPoint = .zero
    private var originalPosition: CGPoint = .zero
    
    // Layout Constants
    private let slotSize = CGSize(width: 300, height: 60)
    private let cardSize = CGSize(width: 130, height: 55)
    
    override func didMove(to view: SKView) {
        backgroundColor = GameTheme.skBackground
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFill
        self.isUserInteractionEnabled = true // Explicitly enable
        setupLayout()
    }
    
    private func setupLayout() {
        removeAllChildren()
        slots.removeAll()
        cards.removeAll()
        
        guard let engine = gameEngine else { return }
        
        // Layout Config
        let safeAreaTop = view?.safeAreaInsets.top ?? 47
        let topBarHeight: CGFloat = 80
        let totalTopOffset = safeAreaTop + topBarHeight
        
        let startY = (size.height / 2) - totalTopOffset - 25
        let slotSpacing: CGFloat = 68 
        
        // Render Slots based on engine.currentLevelSteps (Correct Slots)
        for (i, _) in engine.currentLevelSteps.enumerated() {
            let slot = SKShapeNode(rectOf: slotSize, cornerRadius: 16)
            slot.fillColor = SKColor.white.withAlphaComponent(0.6)
            slot.strokeColor = GameTheme.skPrimaryGreen.withAlphaComponent(0.2)
            slot.lineWidth = 2
            
            slot.userData = ["index": i]
            slot.position = CGPoint(x: 0, y: startY - (CGFloat(i) * slotSpacing))
            
            // Indicator
            // Always show 1..N for slots
            // (Unless hard mode hides indicators, which could be a level.rule check later)
            let indicator = SKShapeNode(circleOfRadius: 14)
            indicator.fillColor = GameTheme.skPrimaryGreen
            indicator.strokeColor = .clear
            indicator.position = CGPoint(x: -slotSize.width/2 + 25, y: 0)
            slot.addChild(indicator)
            
            let num = SKLabelNode(text: "\(i + 1)")
            num.fontName = "SFProRounded-Bold"
            num.fontSize = 16
            num.fontColor = .white
            num.verticalAlignmentMode = .center
            indicator.addChild(num)
            
            let placeholder = SKLabelNode(text: "Step \(i+1)") // Simplified
            placeholder.fontName = "SFProRounded-Medium"
            placeholder.fontSize = 14
            placeholder.fontColor = GameTheme.skTextDark.withAlphaComponent(0.3)
            placeholder.verticalAlignmentMode = .center
            slot.addChild(placeholder)
            
            addChild(slot)
            slots.append(slot)
        }
        
        // Setup Cards using engine.activeCards (includes distractors)
        setupCards(steps: engine.activeCards)
    }
    
    private func setupCards(steps: [WudhuStepModel]) {
        let safeAreaBottom = view?.safeAreaInsets.bottom ?? 34
        let cardsCenterY = (-size.height / 2) + safeAreaBottom + 90
        
        let spacingX: CGFloat = 145
        let spacingY: CGFloat = 65
        
        for (i, step) in steps.enumerated() {
            let card = CardNode(step: step, size: cardSize)
            
            let col = i % 2 
            let row = i / 2 
            
            let xPos = (CGFloat(col) * spacingX) - (spacingX / 2)
            let yPos = cardsCenterY + spacingY - (CGFloat(row) * spacingY)
            
            card.position = CGPoint(x: xPos, y: yPos)
            card.zPosition = 10
            
            addChild(card)
            cards.append(card)
        }
    }
    
    // MARK: - Interactions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Iterate through cards in reverse Z order (top most first)
        // We filter active cards and check if they contain the touch point
        // Using `cards` array is safer than `nodes(at:)`
        
        // We iterate reversed so we pick up the top-most card if they overlap
        for card in cards.reversed() {
             if !card.isUserInteractionEnabled { continue }
            
             // Create a slightly larger hit area for better UX
             let hitFrame = card.calculateAccumulatedFrame().insetBy(dx: -10, dy: -10)
            
             if hitFrame.contains(location) {
                 draggingCard = card
                 originalPosition = card.position
                 touchOffset = CGPoint(x: location.x - card.position.x, y: location.y - card.position.y)
                 
                 card.setHighlight(true)
                 card.zPosition = 1000
                 
                 let impact = UIImpactFeedbackGenerator(style: .light)
                 impact.impactOccurred()
                 return
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
        
        var dropped = false
        
        for slot in slots {
            if slot.contains(card.position) {
                if let index = slot.userData?["index"] as? Int {
                    if gameEngine?.validateDrop(step: card.step, atSlotIndex: index) == true {
                        dropped = true
                        handleSuccessfulDrop(card: card, slot: slot)
                        break
                    }
                }
            }
        }
        
        if !dropped {
            returnCardToOriginal(card: card)
        }
        
        card.setHighlight(false)
        if !dropped { card.zPosition = 10 }
        draggingCard = nil
    }
    
    private func handleSuccessfulDrop(card: CardNode, slot: SKShapeNode) {
        let moveAction = SKAction.move(to: slot.position, duration: 0.15)
        moveAction.timingMode = .easeOut
        card.run(moveAction)
        
        card.isUserInteractionEnabled = false
        card.zPosition = 5
        
        slot.fillColor = GameTheme.skSuccess.withAlphaComponent(0.15)
        slot.strokeColor = GameTheme.skSuccess
        
        emitParticles(at: slot.position)
        let sound = SKAction.playSoundFileNamed("success.wav", waitForCompletion: false)
        run(sound)
    }
    
    private func returnCardToOriginal(card: CardNode) {
        let moveBack = SKAction.move(to: originalPosition, duration: 0.2)
        moveBack.timingMode = .easeOut
        card.run(moveBack)
        
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -5, y: 0, duration: 0.05)
        ])
        card.run(shake)
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func emitParticles(at pos: CGPoint) {
        for _ in 0...8 {
            let p = SKShapeNode(circleOfRadius: 3)
            p.fillColor = GameTheme.skGold
            p.strokeColor = .clear
            p.position = pos
            p.zPosition = 20
            addChild(p)
            
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let distance = CGFloat.random(in: 15...40)
            
            let action = SKAction.group([
                SKAction.moveBy(x: cos(angle) * distance, y: sin(angle) * distance, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.scale(to: 0, duration: 0.3)
            ])
            p.run(SKAction.sequence([action, SKAction.removeFromParent()]))
        }
    }
}
