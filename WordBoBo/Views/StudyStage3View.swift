//
//  StudyStage3View.swift
//  WordBoBo
//  第三遍：显示中文和音标，用户输入英文单词

import SwiftUI

struct StudyStage3View: View {
    @EnvironmentObject var wordStore: WordStore
    @State private var inputText = ""
    @State private var showingFeedback = false
    @State private var feedbackCorrect = false
    @State private var focusedField = false

    var body: some View {
        Group {
            if let session = wordStore.currentSession,
               let currentWord = session.currentWords[safe: session.currentIndex] {
                Stage3WordCard(word: currentWord, inputText: $inputText, showingFeedback: $showingFeedback, feedbackCorrect: $feedbackCorrect)
            } else {
                CompletionView(stage: 3) {
                    wordStore.completeSession()
                }
            }
        }
        .background(LiquidGlassBackground())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 8) {
                    Text("第 3 步：拼写单词")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    ForEach(1...3, id: \.self) { stage in
                        Circle()
                            .fill(stage <= 3 ? Color.orange : Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
    }
}

struct Stage3WordCard: View {
    let word: Word
    @Binding var inputText: String
    @Binding var showingFeedback: Bool
    @Binding var feedbackCorrect: Bool
    @FocusState private var focusedField: Bool

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 32) {
                    // Word info card (no English word shown)
                    VStack(spacing: 20) {
                        if !word.phonetic.isEmpty {
                            Text(word.phonetic)
                                .font(.system(size: 22, design: .monospaced))
                                .foregroundStyle(.cyan.opacity(0.9))
                        }

                        // Chinese meaning
                        Text(word.chineseMeaning)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

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
                                        colors: [.orange.opacity(0.3), .yellow.opacity(0.3)],
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
                    .shadow(color: .orange.opacity(0.15), radius: 30, x: 0, y: 15)

                    // Input area
                    VStack(spacing: 16) {
                        Text("请输入这个单词的英文拼写")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))

                        TextField("输入英文单词...", text: $inputText)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(focusedField ? Color.orange : Color.white.opacity(0.15), lineWidth: 1.5)
                                    )
                            )
                            .focused($focusedField)
                            .autocapitalization(.none)
                            .submitLabel(.done)
                            .onSubmit {
                                checkAnswer()
                            }

                        // Show correct answer after feedback
                        if showingFeedback {
                            VStack(spacing: 8) {
                                Text(feedbackCorrect ? "✅ 回答正确！" : "❌ 正确答案：\(word.text)")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(feedbackCorrect ? .green : .red)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)

                    // Check button
                    Button(action: checkAnswer) {
                        Text("确认答案")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .yellow],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .padding(.horizontal, 40)
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || showingFeedback)

                    // Progress
                    VStack(spacing: 12) {
                        ProgressView(value: Double(wordStore.currentSession?.currentIndex ?? 0),
                                     total: Double(wordStore.currentSession?.currentWords.count ?? 1))
                        .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                        .padding(.horizontal, 40)

                        Text("\(wordStore.currentSession?.currentIndex ?? 0) / \(wordStore.currentSession?.currentWords.count ?? 0)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .padding(.top, 10)
                }

                Spacer()
            }
        }
        .onAppear {
            focusedField = true
        }
        .navigationBarHidden(true)
    }

    private func checkAnswer() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let correct = trimmed == word.text.lowercased()

        showingFeedback = true
        feedbackCorrect = correct

        // Update word status
        if var session = wordStore.currentSession,
           let idx = session.words.firstIndex(where: { $0.id == word.id }) {
            session.words[idx].status = correct ? .correct : .wrong
            wordStore.currentSession = session
        }

        // Auto advance after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + (correct ? 1.0 : 2.0)) {
            inputText = ""
            showingFeedback = false
            wordStore.nextInSession()
        }
    }
}

// MARK: - Completion View
struct CompletionView: View {
    let stage: Int
    let action: () -> Void
    @State private var animating = false

    var stageInfo: (title: String, desc: String, color: Color) {
        switch stage {
        case 1:
            return ("第一遍完成", "接下来进入认识程度判断", .cyan)
        case 2:
            return ("第二遍完成", "接下来进入拼写练习", .green)
        case 3:
            return ("🎉 学习完成！", "本次单词学习已全部完成", .orange)
        default:
            return ("完成", "", .blue)
        }
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 40) {
                Spacer()

                // Emoji animation
                Text(stage == 3 ? "🎉" : "✨")
                    .font(.system(size: 80))
                    .scaleEffect(animating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreversers: true), value: animating)

                VStack(spacing: 12) {
                    Text(stageInfo.title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(stageInfo.desc)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                if stage < 3 {
                    Button(action: action) {
                        HStack(spacing: 10) {
                            Text("继续下一阶段")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [stageInfo.color, stageInfo.color.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .padding(.horizontal, 40)
                } else {
                    Button(action: action) {
                        HStack(spacing: 10) {
                            Image(systemName: "house.fill")
                            Text("返回首页")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .padding(.horizontal, 40)
                }

                Spacer()
            }
            .padding()
        }
        .onAppear { animating = true }
    }
}

// MARK: - Safe Array Access
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
