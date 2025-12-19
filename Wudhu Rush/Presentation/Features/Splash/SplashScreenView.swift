//
//  SplashScreenView.swift
//  Wudhu Rush
//
//  Created by Elmee on 19/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var logoRotation: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var particlesOpacity: Double = 0
    @State private var glowIntensity: Double = 0
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0.5
    @State private var shimmerOffset: CGFloat = -200
    @State private var isAnimationComplete = false
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
            
            // Particle effects
            ParticleEffectsView()
                .opacity(particlesOpacity)
            
            VStack(spacing: 24) {
                Spacer()
                
                // Logo with animations
                ZStack {
                    // Ripple effects
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(GameTheme.primaryGreen.opacity(0.3), lineWidth: 2)
                            .frame(width: 140, height: 140)
                            .scaleEffect(rippleScale)
                            .opacity(rippleOpacity / Double(index + 1))
                            .animation(
                                .easeOut(duration: 2.0)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.4),
                                value: rippleScale
                            )
                    }
                    
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    GameTheme.primaryGreen.opacity(glowIntensity * 0.4),
                                    GameTheme.primaryGreen.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    // Main logo with shimmer effect
                    ZStack {
                        Image("main-icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 175)
                        
                        // Shimmer overlay
                        Image("main-icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 175)
                            .mask(
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .clear,
                                                .white.opacity(0.3),
                                                .clear
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .offset(x: shimmerOffset)
                            )
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .rotationEffect(.degrees(logoRotation))
                    .shadow(
                        color: GameTheme.primaryGreen.opacity(0.5 * logoOpacity),
                        radius: 30,
                        x: 0,
                        y: 15
                    )
                }
                
                // App title with animation
                VStack(spacing: 8) {
                    Text("Wudhu Rush")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    GameTheme.primaryGreen,
                                    GameTheme.darkGreen
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(titleOpacity)
                        .offset(y: titleOffset)
                    
                    Text("Learn Wudhu the fun way!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(GameTheme.textLight)
                        .opacity(titleOpacity * 0.8)
                        .offset(y: titleOffset)
                }
                
                Spacer()
                
                // Loading indicator
                LoadingDotsView()
                    .opacity(titleOpacity)
                    .padding(.bottom, 60)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Ripple effect
        withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
            rippleScale = 3.0
            rippleOpacity = 0
        }
        
        // Logo scale and fade in
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Logo rotation with bounce
        withAnimation(.spring(response: 1.2, dampingFraction: 0.5, blendDuration: 0).delay(0.2)) {
            logoRotation = 360
        }
        
        // Shimmer effect
        withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
            shimmerOffset = 400
        }
        
        // Glow pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.3)) {
            glowIntensity = 1.0
        }
        
        // Title fade in and slide up
        withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
            titleOpacity = 1.0
            titleOffset = 0
        }
        
        // Particles fade in
        withAnimation(.easeIn(duration: 1.0).delay(0.8)) {
            particlesOpacity = 1.0
        }
        
        // Complete animation and transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isAnimationComplete = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete()
            }
        }
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                GameTheme.background,
                GameTheme.lightGreen,
                GameTheme.background
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Particle Effects
struct ParticleEffectsView: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var delay: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(GameTheme.primaryGreen.opacity(0.3))
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                        .modifier(FloatingModifier(delay: particle.delay))
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
            }
        }
    }
    
    private func generateParticles(in size: CGSize) {
        particles = (0..<20).map { index in
            Particle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 4...12),
                opacity: Double.random(in: 0.2...0.6),
                delay: Double(index) * 0.1
            )
        }
    }
}

// MARK: - Floating Animation Modifier
struct FloatingModifier: ViewModifier {
    @State private var isFloating = false
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -20 : 20)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    isFloating.toggle()
                }
            }
    }
}

// MARK: - Loading Dots
struct LoadingDotsView: View {
    @State private var animatingDots = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(GameTheme.primaryGreen)
                    .frame(width: 10, height: 10)
                    .scaleEffect(animatingDots ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animatingDots
                    )
            }
        }
        .onAppear {
            animatingDots = true
        }
    }
}

#Preview {
    SplashScreenView(onComplete: {})
}
