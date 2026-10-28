//
//  ManualInputView.swift
//  WordBoBo
//

import SwiftUI

struct ManualInputView: View {
    @EnvironmentObject var wordStore: WordStore
    var onComplete: ([Word]) -> Void

    @State private var inputText = ""
    @State private var detectedWords: [Word] = []

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        Text("粘贴或输入单词列表")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.top, 20)

                        TextEditor(text: $inputText)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.white)
                            .padding(16)
                            .background(.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.15), lineWidth: 1)
                            )
                            .cornerRadius(16)
                            .frame(height: 250)
                            .padding(.horizontal, 32)

                        Button("解析单词") {
                            detectedWords = wordStore.parseWords(from: inputText)
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.cyan.opacity(0.8))
                        )
                        .padding(.horizontal, 32)

                        if !detectedWords.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("识别到 \(detectedWords.count) 个单词")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)

                                ForEach(detectedWords) { word in
                                    HStack(spacing: 10) {
                                        Text(word.text)
                                            .font(.body.weight(.medium))
                                            .foregroundStyle(.white)

                                        if !word.phonetic.isEmpty {
                                            Text(word.phonetic)
                                                .font(.caption.monospaced())
                                                .foregroundStyle(.cyan.opacity(0.8))
                                        }

                                        Spacer()

                                        if !word.chineseMeaning.isEmpty {
                                            Text(word.chineseMeaning)
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.5))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.white.opacity(0.05))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.white.opacity(0.08), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                            .padding(.horizontal, 32)
                        }

                        Button("开始学习") {
                            onComplete(detectedWords)
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .padding(.horizontal, 32)
                        .padding(.top, 20)
                        .disabled(detectedWords.isEmpty)
                        .opacity(detectedWords.isEmpty ? 0.5 : 1.0)
                    }
                }
            }
            .navigationTitle("手动输入")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { }
                        .foregroundStyle(.cyan)
                }
            }
        }
    }
}
