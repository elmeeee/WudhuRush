//
//  VoiceChallengeView.swift
//  Wudhu Rush
//
//  Created by Elmee on 17/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct VoiceChallengeView: View {
    @ObservedObject var engine: GameEngine
    @ObservedObject var localization = LocalizationManager.shared
    @State private var showPermissionAlert = false
    @State private var recordingPulse = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Progress Indicator
            HStack(spacing: 8) {
                ForEach(0..<engine.targetSlotCount, id: \.self) { index in
                    Circle()
                        .fill(index < engine.currentStepIndex ? GameTheme.primaryGreen : GameTheme.lightGreen)
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Current Step Display
            VStack(spacing: 20) {
                // Step Number
                Text("\(localization.ui(\UIData.step)) \(engine.currentStepIndex + 1) \(localization.ui(\UIData.of)) \(engine.targetSlotCount)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(GameTheme.textLight)
                
                // Arabic Text
                if let arabicText = engine.getCurrentArabicText() {
                    Text(arabicText)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(GameTheme.primaryGreen)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Romanization
                if let romanization = engine.getCurrentRomanization() {
                    Text(romanization)
                        .font(.title3)
                        .foregroundColor(GameTheme.textDark)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // English Translation
                if engine.currentStepIndex < engine.currentLevelSteps.count {
                    Text(engine.currentLevelSteps[engine.currentStepIndex].title)
                        .font(.subheadline)
                        .foregroundColor(GameTheme.textLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(20)
            .padding(.horizontal)
            
            Spacer()
            
            // Recognized Text Display
            if let recognizer = engine.speechRecognizer, !recognizer.recognizedText.isEmpty {
                VStack(spacing: 8) {
                    Text(localization.ui(\UIData.you_said))
                        .font(.caption)
                        .foregroundColor(GameTheme.textLight)
                    
                    Text(recognizer.recognizedText)
                        .font(.body)
                        .foregroundColor(GameTheme.textDark)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(GameTheme.lightGreen.opacity(0.3))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            // Microphone Button
            Button(action: {
                handleMicrophoneTap()
            }) {
                ZStack {
                    // Pulse effect when recording
                    if let recognizer = engine.speechRecognizer, recognizer.isRecording {
                        Circle()
                            .fill(GameTheme.primaryGreen.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .scaleEffect(recordingPulse ? 1.2 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true),
                                value: recordingPulse
                            )
                    }
                    
                    Circle()
                        .fill(engine.speechRecognizer?.isRecording == true ? GameTheme.error : GameTheme.primaryGreen)
                        .frame(width: 80, height: 80)
                        .shadow(color: GameTheme.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: engine.speechRecognizer?.isRecording == true ? "stop.fill" : "mic.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 40)
            
            // Instructions
            Text(engine.speechRecognizer?.isRecording == true ? 
                 localization.ui(\UIData.tap_to_stop) : 
                 localization.ui(\UIData.tap_to_start))
                .font(.caption)
                .foregroundColor(GameTheme.textLight)
                .padding(.bottom, 20)
        }
        .onAppear {
            requestPermissions()
        }
        .alert(localization.ui(\UIData.mic_permission_title), isPresented: $showPermissionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(localization.ui(\UIData.mic_permission_message))
        }
    }
    
    private func requestPermissions() {
        engine.speechRecognizer?.requestAuthorization { granted in
            if !granted {
                showPermissionAlert = true
            }
        }
    }
    
    private func handleMicrophoneTap() {
        guard let recognizer = engine.speechRecognizer else { return }
        
        if recognizer.isRecording {
            // Stop recording and validate
            recognizer.stopRecording()
            recordingPulse = false
            
            // Wait a bit for final transcription
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let isCorrect = engine.validateVoiceInput()
                
                // Show feedback
                if isCorrect {
                    // Success haptic
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                } else {
                    // Error haptic
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
            }
        } else {
            // Start recording
            do {
                try recognizer.startRecording()
                recordingPulse = true
            } catch {
                print("Failed to start recording: \(error)")
            }
        }
    }
}
