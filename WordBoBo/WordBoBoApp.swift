//
//  WordBoBoApp.swift
//  WordBoBo
//

import SwiftUI

@main
struct WordBoBoApp: App {
    @StateObject private var wordStore = WordStore.shared
    @StateObject private var ocrService = OCRService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(wordStore)
                .environmentObject(ocrService)
                .preferredColorScheme(.dark)
        }
    }
}
