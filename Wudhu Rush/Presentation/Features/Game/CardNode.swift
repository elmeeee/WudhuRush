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
        self.background = SKShapeNode(rectOf: size, cornerRadius: 14)
        self.label = SKLabelNode(fontNamed: "SFProRounded-Bold")
        
        super.init()

        // Enhanced shadow with blur effect
        let shadow = SKShapeNode(rectOf: CGSize(width: size.width + 4, height: size.height + 4), cornerRadius: 14)
        shadow.fillColor = .black
        shadow.alpha = 0.12
        shadow.lineWidth = 0
        shadow.position = CGPoint(x: 0, y: -4)
        shadow.zPosition = -2
        addChild(shadow)
        
        // Subtle gradient effect (lighter top)
        let gradientTop = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height / 3), cornerRadius: 0)
        gradientTop.fillColor = .white
        gradientTop.alpha = 0.3
        gradientTop.lineWidth = 0
        gradientTop.position = CGPoint(x: 0, y: size.height / 3)
        gradientTop.zPosition = 0.5
        background.addChild(gradientTop)
        
        background.fillColor = GameTheme.skSurface
        background.strokeColor = GameTheme.skLightGreen
        background.lineWidth = 2
        addChild(background)
        
        label.text = step.title
        label.fontSize = 14
        label.fontColor = GameTheme.skTextDark
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.preferredMaxLayoutWidth = size.width - 20
        label.numberOfLines = 2
        label.position = CGPoint(x: 0, y: 0)
        label.zPosition = 1
        addChild(label)
        
        self.name = "card-\(step.id)"
        
        // Initial subtle animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 1.5),
            SKAction.moveBy(x: 0, y: -3, duration: 1.5)
        ])
        run(SKAction.repeatForever(float))
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
            // Smooth scale up with spring
            let scaleAction = SKAction.scale(to: 1.12, duration: 0.15)
            scaleAction.timingMode = .easeOut
            run(scaleAction)
            
            background.strokeColor = GameTheme.skGold
            background.lineWidth = 3
            background.fillColor = SKColor.white
            
            // Subtle rotation
            run(SKAction.rotate(byAngle: CGFloat.random(in: -0.03...0.03), duration: 0.1))
        } else {
            // Smooth scale down
            let scaleAction = SKAction.scale(to: 1.0, duration: 0.15)
            scaleAction.timingMode = .easeIn
            run(scaleAction)
            
            run(SKAction.rotate(toAngle: 0, duration: 0.1))
            background.strokeColor = GameTheme.skLightGreen
            background.lineWidth = 2
            background.fillColor = GameTheme.skSurface
        }
    }
}
