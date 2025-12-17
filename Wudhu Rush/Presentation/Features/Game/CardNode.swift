//
//  CardNode.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import Swift
import SpriteKit

class CardNode: SKNode {
    let step: WudhuStepModel
    private let background: SKShapeNode
    private let label: SKLabelNode
    private let cardSize: CGSize
    var isInteractive: Bool = true
    
    init(step: WudhuStepModel, size: CGSize) {
        self.step = step
        self.cardSize = size
        self.background = SKShapeNode(rectOf: size, cornerRadius: 12)
        self.label = SKLabelNode(fontNamed: "SFProRounded-Bold")
        
        super.init()

        let shadow = SKShapeNode(rectOf: size, cornerRadius: 12)
        shadow.fillColor = .black
        shadow.alpha = 0.15
        shadow.lineWidth = 0
        shadow.position = CGPoint(x: 2, y: -3)
        shadow.zPosition = -1
        addChild(shadow)
        
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
    
    func containsTouch(_ point: CGPoint) -> Bool {
        let dx = point.x - self.position.x
        let dy = point.y - self.position.y
        let halfW = (cardSize.width / 2) + 20
        let halfH = (cardSize.height / 2) + 20
        
        return abs(dx) < halfW && abs(dy) < halfH
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
