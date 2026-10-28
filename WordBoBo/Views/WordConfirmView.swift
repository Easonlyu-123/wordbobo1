//
//  WordConfirmView.swift
//  WordBoBo
//

import SwiftUI

struct WordConfirmView: View {
    @Binding var words: [Word]
    var onConfirm: ([Word]) -> Void

    @State private var selectedWords: Set<UUID> = []
    @Environment(\\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(words) { word in
                            WordConfirmRow(
                                word: word,
                                isSelected: selectedWords.contains(word.id)
                            ) {
                                if selectedWords.contains(word.id) {
                                    selectedWords.remove(word.id)
                                } else {
                                    selectedWords.insert(word.id)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                }

                VStack {
                    HStack {
                        Button("全选") { selectedWords = Set(words.map { $0.id }) }
                            .font(.subheadline).foregroundStyle(.cyan)
                        Spacer()
                        Text("已选 \(selectedWords.count) / \(words.count)")
                            .font(.subheadline).foregroundStyle(.white.opacity(0.6))
                        Spacer()
                        Button("全不选") { selectedWords.removeAll() }
                            .font(.subheadline).foregroundStyle(.cyan)
                    }
                    .padding(.horizontal, 32)

                    Button("开始学习") {
                        let selected = words.filter { selectedWords.contains($0.id) }
                        let final = selected.isEmpty ? words : selected
                        onConfirm(final)
                        dismiss()
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)))
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                    .disabled(selectedWords.isEmpty && !words.isEmpty)
                    .opacity(selectedWords.isEmpty && !words.isEmpty ? 0.5 : 1.0)
                }
                .background(.ultraThinMaterial)
            }
            .navigationTitle("确认单词")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("返回") { dismiss() }.foregroundStyle(.cyan)
                }
            }
        }
        .onAppear {
            selectedWords = Set(words.map { $0.id })
        }
    }
}

struct WordConfirmRow: View {
    let word: Word
    let isSelected: Bool
    let toggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.cyan : Color.white.opacity(0.1))
                    .frame(width: 28, height: 28)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color.cyan : Color.white.opacity(0.2), lineWidth: 1.5))
                if isSelected { Image(systemName: "checkmark").font(.system(size: 14, weight: .bold)).foregroundStyle(.white) }
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(word.text).font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundStyle(.white)
                    if !word.phonetic.isEmpty { Text(word.phonetic).font(.system(size: 13, design: .monospaced)).foregroundStyle(.cyan.opacity(0.8)) }
                }
                HStack(spacing: 8) {
                    if !word.partOfSpeech.isEmpty {
                        Text(word.partOfSpeech).font(.caption).padding(.horizontal, 8).padding(.vertical, 2).background(.cyan.opacity(0.15)).foregroundStyle(.cyan).clipShape(Capsule())
                    }
                    if !word.chineseMeaning.isEmpty { Text(word.chineseMeaning).font(.caption).foregroundStyle(.white.opacity(0.5)) }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial).overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color.cyan.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)))
        .onTapGesture { toggle() }
    }
}
