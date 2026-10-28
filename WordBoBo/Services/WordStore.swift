//
//  WordStore.swift
//  WordBoBo
//

import Foundation
import SwiftUI

class WordStore: ObservableObject {
    static let shared = WordStore()

    @Published var currentSession: StudySession?
    @Published var allWords: [Word] = []
    @Published var completedSessions: [StudySession] = []
    @Published var studyHistory: [Date: [UUID]] = []
    @Published var pendingWords: [Word] = []

    private let wordsKey = "allWords"
    private let historyKey = "studyHistory"
    private let completedKey = "completedSessions"

    private init() { load() }

    // MARK: - Parse OCR text
    func parseWords(from text: String) -> [Word] {
        let lines = text.components(separatedBy: .newlines)
        var words: [Word] = []
        let dict = LocalDictionary.dictionary

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            var wordText = ""
            var phonetic = ""
            var pos = ""
            var meaning = ""

            let pattern1 = try? NSRegularExpression(pattern: "^([a-zA-Z][a-zA-Z\\s]+?)\\s+(/[^/]+/)\\s+([a-z.]+)\\s+(.+)$")
            let pattern2 = try? NSRegularExpression(pattern: "^([a-zA-Z][a-zA-Z\\s]+?)\\s+([a-z.]+)\\s+(.+)$")
            let pattern3 = try? NSRegularExpression(pattern: "^([a-zA-Z][a-zA-Z\\s]+?)\\s{2,}(.+)$")

            let range = NSRange(location: 0, length: trimmed.utf16.count)

            if let m = pattern1?.firstMatch(in: trimmed, options: [], range: range) {
                wordText = (trimmed as NSString).substring(with: m.range(at: 1)).trimmingCharacters(in: .whitespaces)
                phonetic = (trimmed as NSString).substring(with: m.range(at: 2))
                pos = (trimmed as NSString).substring(with: m.range(at: 3))
                meaning = (trimmed as NSString).substring(with: m.range(at: 4))
            } else if let m = pattern2?.firstMatch(in: trimmed, options: [], range: range) {
                wordText = (trimmed as NSString).substring(with: m.range(at: 1)).trimmingCharacters(in: .whitespaces)
                pos = (trimmed as NSString).substring(with: m.range(at: 2))
                meaning = (trimmed as NSString).substring(with: m.range(at: 3))
                if let d = dict[wordText.lowercased()] {
                    if phonetic.isEmpty { phonetic = d.phonetic }
                    if pos.isEmpty { pos = d.pos }
                    if meaning.isEmpty { meaning = d.meaning }
                }
            } else if let m = pattern3?.firstMatch(in: trimmed, options: [], range: range) {
                wordText = (trimmed as NSString).substring(with: m.range(at: 1)).trimmingCharacters(in: .whitespaces)
                meaning = (trimmed as NSString).substring(with: m.range(at: 2))
                if let d = dict[wordText.lowercased()] {
                    phonetic = d.phonetic; pos = d.pos
                }
            } else {
                wordText = trimmed
                if let d = dict[wordText.lowercased()] {
                    phonetic = d.phonetic; pos = d.pos; meaning = d.meaning
                }
            }

            wordText = wordText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !wordText.isEmpty else { continue }
            let letterCount = wordText.filter { $0.isLetter || $0 == " " }.count
            guard letterCount > 0 else { continue }
            if words.first(where: { $0.text.lowercased() == wordText.lowercased() }) == nil {
                words.append(Word(text: wordText, phonetic: phonetic, partOfSpeech: pos, chineseMeaning: meaning))
            }
        }
        return words
    }

    // MARK: - Study Session
    func startSession(with words: [Word]) {
        currentSession = StudySession(words: words)
    }

    func nextInSession() {
        guard var s = currentSession else { return }
        s.nextWord()
        currentSession = s
    }

    func completeSession() {
        guard var s = currentSession else { return }
        s.endTime = Date()
        completedSessions.append(s)

        let today = Calendar.current.startOfDay(for: Date())
        var todayWords = studyHistory[today] ?? []
        s.words.forEach { todayWords.append($0.id) }
        studyHistory[today] = todayWords

        for word in s.words {
            if let idx = allWords.firstIndex(where: { $0.id == word.id }) {
                allWords[idx] = word
            } else {
                allWords.append(word)
            }
        }
        currentSession = nil
        save()
    }

    // MARK: - Persistence
    private func save() {
        if let d = try? JSONEncoder().encode(allWords) { UserDefaults.standard.set(d, forKey: wordsKey) }
        if let d = try? JSONEncoder().encode(studyHistory) { UserDefaults.standard.set(d, forKey: historyKey) }
        if let d = try? JSONEncoder().encode(completedSessions) { UserDefaults.standard.set(d, forKey: completedKey) }
    }

    private func load() {
        if let d = UserDefaults.standard.data(forKey: wordsKey), let w = try? JSONDecoder().decode([Word].self, from: d) { allWords = w }
        if let d = UserDefaults.standard.data(forKey: historyKey), let h = try? JSONDecoder().decode([Date: [UUID]].self, from: d) { studyHistory = h }
        if let d = UserDefaults.standard.data(forKey: completedKey), let s = try? JSONDecoder().decode([StudySession].self, from: d) { completedSessions = s }
    }
}
