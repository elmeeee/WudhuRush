//
//  SpeechRecognitionManager.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import Foundation
import Speech
import AVFoundation
import Combine

final class SpeechRecognitionManager: NSObject, ObservableObject, @unchecked Sendable {
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    
    override init() {
        super.init()
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))
        authorizationStatus = SFSpeechRecognizer.authorizationStatus()
    }
    
    // MARK: - Permissions
    
    func requestAllPermissions(completion: @escaping (Bool) -> Void) {
        // Request speech first
        SFSpeechRecognizer.requestAuthorization { [weak self] speechStatus in
            DispatchQueue.main.async {
                self?.authorizationStatus = speechStatus
                
                guard speechStatus == .authorized else {
                    completion(false)
                    return
                }
                
                // Then request microphone
                AVAudioApplication.requestRecordPermission { micGranted in
                    DispatchQueue.main.async {
                        completion(micGranted)
                    }
                }
            }
        }
    }
    
    func startRecording() throws {
        // Cancel any ongoing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Create new audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw NSError(domain: "SpeechRecognition", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to create audio engine"])
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "SpeechRecognition", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Get input node
        let inputNode = audioEngine.inputNode
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.recognizedText = text
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine?.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                DispatchQueue.main.async {
                    self.isRecording = false
                }
            }
        }
        
        // Configure microphone input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
        
        DispatchQueue.main.async {
            self.isRecording = true
            self.recognizedText = ""
        }
    }
    
    func stopRecording() {
        audioEngine?.stop()
        recognitionRequest?.endAudio()
        
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
    
    func matchesExpectedText(_ expected: String, tolerance: Double = 0.7) -> Bool {
        let similarity = calculateSimilarity(recognizedText, expected)
        return similarity >= tolerance
    }
    
    private func calculateSimilarity(_ text1: String, _ text2: String) -> Double {
        let normalized1 = normalizeArabicText(text1)
        let normalized2 = normalizeArabicText(text2)
        
        let distance = levenshteinDistance(normalized1, normalized2)
        let maxLength = max(normalized1.count, normalized2.count)
        
        guard maxLength > 0 else { return 1.0 }
        
        return 1.0 - (Double(distance) / Double(maxLength))
    }
    
    private func normalizeArabicText(_ text: String) -> String {
        let diacritics: [Character] = ["ً", "ٌ", "ٍ", "َ", "ُ", "ِ", "ّ", "ْ", "ٓ", "ٰ"]
        var normalized = text
        
        for diacritic in diacritics {
            normalized = normalized.replacingOccurrences(of: String(diacritic), with: "")
        }
        
        return normalized.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let m = s1Array.count
        let n = s2Array.count
        
        guard m > 0 && n > 0 else { return max(m, n) }
        
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m {
            matrix[i][0] = i
        }
        
        for j in 0...n {
            matrix[0][j] = j
        }
        
        for i in 1...m {
            for j in 1...n {
                let cost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }
        
        return matrix[m][n]
    }
}

