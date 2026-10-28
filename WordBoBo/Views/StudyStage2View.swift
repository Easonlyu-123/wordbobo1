//
//  StudyStage2View.swift
//  WordBoBo
//  第二遍：显示英文和词性，用户点"会"或"不会"

import SwiftUI

struct StudyStage2View: View {
    @EnvironmentObject var wordStore: WordStore

    var body: some View {
        Group {
            if let session = wordStore.currentSession,
               let currentWord = session.currentWords[safe: session.currentIndex] {
                Stage2WordCard(word: currentWord)
            } else {
                // Move to stage 3
                CompletionView(stage: 2) {
                    guard var session = wordStore.currentSession else { return }
                    session.advanceStage()
                    wordStore.currentSession = session
                }
            }
        }
        .background(LiquidGlassBackground())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 8) {
                    Text("第 2 步：认识程度")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    ForEach(1...3, id: \.self) { stage in
                        Circle()
                            .fill(stage <= 2 ? Color.green : Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
    }
}

struct Stage2WordCard: View {
    let word: Word
    @State private var speechService = SpeechService.shared

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 32) {
                    // Word card
                    VStack(spacing: 20) {
                        Text(word.text.capitalized)
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .onTapGesture {
                                speechService.speak(word.text)
                            }

                        if !word.partOfSpeech.isEmpty {
                            Text(word.partOfSpeech)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.purple.opacity(0.9))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(.purple.opacity(0.15))
                                        .overlay(Capsule().stroke(.purple.opacity(0.3), lineWidth: 1))
                                )
                        }

                        Text("点击单词听发音")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
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
                                        colors: [.green.opacity(0.3), .teal.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )

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
                    .shadow(color: .green.opacity(0.15), radius: 30, x: 0, y: 15)

                    // Progress
                    VStack(spacing: 12) {
                        ProgressView(value: Double(wordStore.currentSession?.currentIndex ?? 0),
                                     total: Double(wordStore.currentSession?.currentWords.count ?? 1))
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .padding(.horizontal, 40)

                        Text("\(wordStore.currentSession?.currentIndex ?? 0) / \(wordStore.currentSession?.currentWords.count ?? 0)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .padding(.top, 20)
                }

                Spacer()

                // Yes/No buttons
                HStack(spacing: 20) {
                    // Don't know
                    Button(action: {
                        if var session = wordStore.currentSession,
                           let idx = session.words.firstIndex(where: { $0.id == word.id }) {
                            session.words[idx].status = .unknownWord
                            wordStore.currentSession = session
                        }
                        wordStore.nextInSession()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                            Text("不会")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [.red.opacity(0.7), .orange.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }

                    // Know it
                    Button(action: {
                        if var session = wordStore.currentSession,
                           let idx = session.words.firstIndex(where: { $0.id == word.id }) {
                            session.words[idx].status = .known
                            wordStore.currentSession = session
                        }
                        wordStore.nextInSession()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 32))
                            Text("会了")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .teal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
    }
}
