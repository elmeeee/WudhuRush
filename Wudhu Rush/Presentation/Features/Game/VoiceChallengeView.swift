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
    @State private var showFeedbackAlert = false
    @State private var feedbackMessage = ""
    @State private var feedbackIsCorrect = false
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
                        .foregroundColor(GameTheme.textLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
            
            Spacer()
            
            // Voice Recognition Display
            VStack(spacing: 12) {
                Text(localization.ui(\UIData.you_said))
                    .font(.caption)
                    .foregroundColor(GameTheme.textLight)
                
                Text(engine.speechRecognizer?.recognizedText ?? "...")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(GameTheme.textDark)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 60)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(GameTheme.background)
                    )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Microphone Button
            Button(action: handleMicrophoneTap) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [GameTheme.primaryGreen, GameTheme.primaryGreen.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: GameTheme.primaryGreen.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    if recordingPulse {
                        Circle()
                            .stroke(GameTheme.primaryGreen.opacity(0.5), lineWidth: 4)
                            .frame(width: 120, height: 120)
                            .scaleEffect(recordingPulse ? 1.2 : 1.0)
                            .opacity(recordingPulse ? 0 : 1)
                            .animation(
                                .easeInOut(duration: 1.0).repeatForever(autoreverses: false),
                                value: recordingPulse
                            )
                    }
                    
                    Image(systemName: engine.speechRecognizer?.isRecording == true ? "stop.fill" : "mic.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 40)
            
            Text(engine.speechRecognizer?.isRecording == true ? 
                 localization.ui(\UIData.tap_to_stop) : 
                 localization.ui(\UIData.tap_to_start))
                .font(.caption)
                .foregroundColor(GameTheme.textLight)
                .padding(.bottom, 20)
        }
        .alert(localization.ui(\UIData.mic_permission_title), isPresented: $showPermissionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(localization.ui(\UIData.mic_permission_message))
        }
        .alert(feedbackMessage, isPresented: $showFeedbackAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            requestPermissions()
        }
    }
    
    private func requestPermissions() {
        engine.speechRecognizer?.requestAllPermissions { granted in
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
                
                // Show feedback alert
                feedbackIsCorrect = isCorrect
                feedbackMessage = isCorrect ? 
                    localization.feedback(\FeedbackData.correct) : 
                    localization.feedback(\FeedbackData.incorrect)
                showFeedbackAlert = true
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(isCorrect ? .success : .error)
                
                // Auto-dismiss alert after 1.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showFeedbackAlert = false
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
