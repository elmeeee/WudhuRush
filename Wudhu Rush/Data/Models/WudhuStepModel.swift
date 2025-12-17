//
//  WudhuStepModel.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import Foundation

struct WudhuStepModel: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let order: Int
    let isDistractor: Bool
    
    var iconName: String {
        return "hand.tap" 
    }
}
