//
//  LocalizationManager.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import Foundation
import Combine


struct GameContentRoot: Codable {
    let en: LocalizedContent
    let id: LocalizedContent
    let ms: LocalizedContent
    let ja: LocalizedContent
    let th: LocalizedContent
    let es: LocalizedContent
}

struct LocalizedContent: Codable {
    let meta: MetaData
    let ui: UIData
    let feedback: FeedbackData
    let achievements: AchievementData
    let endless_mode: EndlessModeData
    let levels: [LevelData]
}

struct MetaData: Codable {
    let language: String
    let code: String
}

struct UIData: Codable {
    let time_attack: String
    let practice: String
    let leaderboard: String
    let play_again: String
    let home: String
    let offline_mode: String
    let perfect_run: String
    let mistake: String
    let time_remaining: String
    let level_select: String
    let game_over: String
    let completed: String
    let locked_level: String
    let final_score: String
    let level: String
    let view_top_scores: String
    let you: String
    let step: String
    let of: String
    let you_said: String
    let tap_to_stop: String
    let tap_to_start: String
    let mic_permission_title: String
    let mic_permission_message: String
}

struct FeedbackData: Codable {
    let correct: String
    let incorrect: String
    let level_completed: String
    let high_score: String
}

struct AchievementData: Codable {
    let beginner: String
    let focused: String
    let perfect_run: String
    let wudhu_master: String
}

struct EndlessModeData: Codable {
    let title: String
    let description: String
    let game_type: String?
    let arabic_steps: [String]?
    let romanization: [String]?
}

struct LevelData: Codable, Identifiable, Hashable {
    let id: String
    let internal_name: String
    let title: String
    let description: String
    let steps: [String]
    let distractors: [String]
    let time_limit: Int
    let rule: String
    let game_type: String // "drag_drop" or "voice_challenge"
    let arabic_steps: [String]? // Arabic text for each step
    let romanization: [String]? // Pronunciation guide
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var languageCode: String = "en"
    @Published var content: LocalizedContent?
    
    private var allContent: GameContentRoot?
    
    private init() {
        loadData()
        let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
        if ["en", "id", "ms", "ja", "th", "es"].contains(systemLang) {
            setLanguage(systemLang)
        } else {
            setLanguage("en")
        }
    }
    
    func loadData() {
        var url = Bundle.main.url(forResource: "GameContent", withExtension: "json")
        if url == nil {
            url = Bundle.main.url(forResource: "GameContent", withExtension: "json", subdirectory: "Resources")
        }
        
        guard let finalUrl = url else {
            print("CRITICAL: GameContent.json not found in Bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: finalUrl)
            let decoder = JSONDecoder()
            self.allContent = try decoder.decode(GameContentRoot.self, from: data)
        } catch {
            print("CRITICAL: Failed to decode GameContent.json: \(error)")
             if let string = try? String(contentsOf: finalUrl) {
                 print("JSON Snippet: \(string.prefix(100))")
             }
        }
    }
    
    func setLanguage(_ code: String) {
        self.languageCode = code
        guard let root = allContent else { return }
        
        switch code {
        case "en": content = root.en
        case "id": content = root.id
        case "ms": content = root.ms
        case "ja": content = root.ja
        case "th": content = root.th
        case "es": content = root.es
        default: content = root.en
        }
    }
    
    func ui(_ key: KeyPath<UIData, String>) -> String {
        return content?.ui[keyPath: key] ?? ""
    }
    
    func feedback(_ key: KeyPath<FeedbackData, String>) -> String {
        return content?.feedback[keyPath: key] ?? ""
    }
}
