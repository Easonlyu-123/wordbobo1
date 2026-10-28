//
//  HistoryView.swift
//  WordBoBo
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var wordStore: WordStore

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView {
                VStack(spacing: 16) {
                    // Stats header
                    HStack(spacing: 20) {
                        StatCard(value: "\(wordStore.allWords.count)", label: "总单词数", color: .cyan)
                        StatCard(value: "\(wordStore.completedSessions.count)", label: "学习次数", color: .green)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)

                    // Session history
                    if wordStore.completedSessions.isEmpty {
                        VStack(spacing: 12) {
                            Text("还没有学习记录")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.4))
                            Text("拍照识别单词后开始第一次学习吧")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.25))
                        }
                        .padding(.top, 60)
                    } else {
                        ForEach(wordStore.completedSessions.reversed()) { session in
                            SessionRow(session: session)
                                .padding(.horizontal, 32)
                        }
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("学习记录")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct SessionRow: View {
    let session: StudySession

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(session.words.count) 个单词")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(formatDate(session.startTime))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))

                // Word status breakdown
                HStack(spacing: 8) {
                    Label("\(session.words.filter { $0.status == .known }.count) 已掌握", systemImage: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.green)

                    Label("\(session.words.filter { $0.status == .unknownWord }.count) 需复习", systemImage: "xmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)

                    Label("\(session.words.filter { $0.status == .wrong }.count) 拼写错", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.2))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
