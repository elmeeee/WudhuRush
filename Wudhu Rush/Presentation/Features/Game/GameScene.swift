//
//  GameScene.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import Swift
import SpriteKit

class GameScene: SKScene {
    
    func forceLayoutUpdate() {
        setupLayout()
    }
    
    func highlightSlot(at index: Int) {
        guard index < slots.count else { return }
        let slot = slots[index]
        
        // Pulse animation
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeat3 = SKAction.repeat(pulse, count: 3)
        
        // Color change
        let originalColor = slot.strokeColor
        slot.strokeColor = GameTheme.skGold
        slot.lineWidth = 4
        
        slot.run(repeat3) {
            slot.strokeColor = originalColor
            slot.lineWidth = 2
        }
    }
    
    weak var gameEngine: GameEngine? {
        didSet {
             if self.scene != nil { setupLayout() }
        }
    }
    
    private var slots: [SKShapeNode] = []
    private var cards: [CardNode] = []
    
    private var draggingCard: CardNode?
    private var touchOffset: CGPoint = .zero
    private var originalPosition: CGPoint = .zero
    private let slotSize = CGSize(width: 300, height: 60)
    private let cardSize = CGSize(width: 130, height: 55)
    
    override func didMove(to view: SKView) {
        backgroundColor = GameTheme.skBackground
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFill
        self.isUserInteractionEnabled = true
        setupLayout()
    }
    
    private func setupLayout() {
        removeAllChildren()
        slots.removeAll()
        cards.removeAll()
        
        guard let engine = gameEngine else { return }
        
        let safeAreaTop = view?.safeAreaInsets.top ?? 47
        let topBarHeight: CGFloat = 180 
        let totalTopOffset = safeAreaTop + topBarHeight
        
        let startY = (size.height / 2) - totalTopOffset
        let slotSpacing: CGFloat = 72
        
        for (i, _) in engine.currentLevelSteps.enumerated() {
            let slot = SKShapeNode(rectOf: slotSize, cornerRadius: 16)
            slot.fillColor = SKColor.white.withAlphaComponent(0.6)
            slot.strokeColor = GameTheme.skPrimaryGreen.withAlphaComponent(0.2)
            slot.lineWidth = 2
            
            slot.userData = ["index": i]
            slot.position = CGPoint(x: 0, y: startY - (CGFloat(i) * slotSpacing))
            
            // Determine if we should show numbers
            let shouldShowNumber: Bool
            if case .practice = engine.gameMode {
                // Practice mode: always show numbers
                shouldShowNumber = true
            } else if case .level(let levelData) = engine.gameMode {
                // Level 1: show numbers only for first 3 slots
                // Level 2+: no numbers
                shouldShowNumber = levelData.id == "L01" && i < 3
            } else {
                shouldShowNumber = false
            }
            
            if shouldShowNumber {
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
            }
            
            let placeholder = SKLabelNode(text: "Step \(i+1)")
            placeholder.fontName = "SFProRounded-Medium"
            placeholder.fontSize = 14
            placeholder.fontColor = GameTheme.skTextDark.withAlphaComponent(0.3)
            placeholder.verticalAlignmentMode = .center
            slot.addChild(placeholder)
            
            addChild(slot)
            slots.append(slot)
        }

        setupCards(steps: engine.activeCards)
    }
    
    private func setupCards(steps: [WudhuStepModel]) {
        let safeAreaBottom = view?.safeAreaInsets.bottom ?? 34
        let cardsCenterY = (-size.height / 2) + safeAreaBottom + 120
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        for card in cards.reversed() {
            if !card.isInteractive { continue }
            if card.containsTouch(location) {
                dragStart(card: card, location: location)
                return
            }
        }
    }
    
    private func dragStart(card: CardNode, location: CGPoint) {
        draggingCard = card
        originalPosition = card.position
        touchOffset = CGPoint(x: location.x - card.position.x, y: location.y - card.position.y)
        
        card.setHighlight(true)
        card.zPosition = 1000
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
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
        
        card.isInteractive = false
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
