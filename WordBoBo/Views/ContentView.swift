//
//  ContentView.swift
//  WordBoBo
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var wordStore: WordStore
    @EnvironmentObject var ocrService: OCRService

    @State private var showingCamera = false
    @State private var isProcessing = false
    @State private var showingHistory = false
    @State private var showingManualInput = false

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()

                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 64, height: 64)
                                .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                            Image(systemName: "book.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(
                                    LinearGradient(colors: [.cyan, .blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("单词背背")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("拍照识别 \u00b7 科学记忆")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    .padding(.bottom, 50)

                    VStack(spacing: 16) {
                        GlassButton(icon: "camera.fill", title: "拍照识别单词", subtitle: "拍摄单词表，自动识别", gradient: Gradient(colors: [.cyan, .blue])) {
                            showingCamera = true
                        }
                        GlassButton(icon: "keyboard", title: "手动输入单词", subtitle: "直接输入或粘贴单词列表", gradient: Gradient(colors: [.purple, .pink])) {
                            showingManualInput = true
                        }
                        GlassButton(icon: "chart.bar.fill", title: "学习记录", subtitle: "查看背词统计", gradient: Gradient(colors: [.green, .teal])) {
                            showingHistory = true
                        }
                    }
                    .padding(.horizontal, 32)

                    Spacer()

                    HStack {
                        Text("已收录单词: \(wordStore.allWords.count)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                        Spacer()
                        Text("已完成学习: \(wordStore.completedSessions.count) \u6b21")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(isPresented: $showingCamera) {
                CameraPreviewView(isProcessing: $isProcessing)
                    .environmentObject(ocrService)
                    .environmentObject(wordStore)
            }
            .navigationDestination(isPresented: $showingHistory) {
                HistoryView().environmentObject(wordStore)
            }
            .sheet(isPresented: $showingManualInput) {
                ManualInputView { words in
                    if !words.isEmpty {
                        wordStore.startSession(with: words)
                    }
                    showingManualInput = false
                }
                .environmentObject(wordStore)
            }
            .background(
                NavigationLink(
                    destination: StudyRouterView().environmentObject(wordStore),
                    isActive: Binding(
                        get: { wordStore.currentSession != nil },
                        set: { if !$0 { wordStore.currentSession = nil } }
                    )
                ) { EmptyView() }
            )
            .overlay {
                if isProcessing {
                    ProcessingOverlay()
                }
            }
        }
    }
}

struct GlassButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: Gradient
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [gradient.stops.first?.color ?? .blue, gradient.stops.last?.color ?? .purple], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.8))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon).font(.system(size: 22)).foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundStyle(.white)
                    Text(subtitle).font(.caption).foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.15), lineWidth: 1)
                    RoundedRectangle(cornerRadius: 24).fill(LinearGradient(colors: [.white.opacity(0.1), .clear], startPoint: .top, endPoint: .bottom))
                }
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .shadow(color: gradient.stops.first?.color.opacity(0.3) ?? .blue.opacity(0.3), radius: isPressed ? 8 : 20, x: 0, y: isPressed ? 4 : 10)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in isPressed = true }.onEnded { _ in isPressed = false })
    }
}

struct ProcessingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 20) {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .cyan)).scaleEffect(1.5)
                Text("正在识别中...").font(.headline).foregroundStyle(.white)
            }
            .padding(40)
            .background(RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial).overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.2), lineWidth: 1)))
        }
    }
}
