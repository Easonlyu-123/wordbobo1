//
//  StudyStage1View.swift
//  WordBoBo
//  第一遍：显示中文、音标、词性，点击发音

import SwiftUI

struct StudyStage1View: View {
    @EnvironmentObject var wordStore: WordStore
    @State private var speechService = SpeechService.shared

    var body: some View {
        Group {
            if let session = wordStore.currentSession,
               let currentWord = session.currentWords[safe: session.currentIndex] {
                Stage1WordCard(word: currentWord, isFirst: session.currentIndex == 0)
            } else {
                CompletionView(stage: 1) {
                    wordStore.completeSession()
                }
            }
        }
        .background(LiquidGlassBackground())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 8) {
                    Text("第 1 步：认识单词")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    ForEach(1...3, id: \.self) { stage in
                        Circle()
                            .fill(stage <= 1 ? Color.cyan : Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
    }
}

struct Stage1WordCard: View {
    let word: Word
    let isFirst: Bool
    @State private var speechService = SpeechService.shared
    @State private var showingDetail = false

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 32) {
                    // Word display card
                    VStack(spacing: 20) {
                        // Phonetic
                        if !word.phonetic.isEmpty {
                            Text(word.phonetic)
                                .font(.system(size: 22, design: .monospaced))
                                .foregroundStyle(.cyan.opacity(0.9))
                        }

                        // English word (tap to pronounce)
                        Button(action: {
                            speechService.speak(word.text)
                        }) {
                            Text(word.text.capitalized)
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                        }

                        // Part of speech
                        if !word.partOfSpeech.isEmpty {
                            Text(word.partOfSpeech)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.purple.opacity(0.9))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(.purple.opacity(0.15))
                                        .overlay(
                                            Capsule()
                                                .stroke(.purple.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }

                        // Chinese meaning
                        VStack(spacing: 8) {
                            Text(word.chineseMeaning)
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("点击单词可听发音")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    .padding(.vertical, 48)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: geo.size.width * 0.92)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 32)
                                .fill(.ultraThinMaterial)

                            RoundedRectangle(cornerRadius: 32)
                                .stroke(
                                    LinearGradient(
                                        colors: [.cyan.opacity(0.3), .purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )

                            // Glass highlight
                            RoundedRectangle(cornerRadius: 32)
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.12), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                    )
                    .shadow(color: .cyan.opacity(0.15), radius: 30, x: 0, y: 15)

                    // Progress
                    VStack(spacing: 12) {
                        ProgressView(value: Double(wordStore.currentSession?.currentIndex ?? 0),
                                     total: Double(wordStore.currentSession?.currentWords.count ?? 1))
                        .progressViewStyle(
                            LinearProgressViewStyle(tint: .cyan)
                        )
                        .padding(.horizontal, 40)

                        Text("\(wordStore.currentSession?.currentIndex ?? 0) / \(wordStore.currentSession?.currentWords.count ?? 0)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .padding(.top, 20)
                }

                Spacer()

                // Next button
                Button(action: {
                    wordStore.nextInSession()
                }) {
                    HStack {
                        Text("下一个")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
    }
}
