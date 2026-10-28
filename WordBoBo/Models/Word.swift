//
//  Word.swift
//  WordBoBo
//

import Foundation

enum WordStatus: String, Codable {
    case unknown = "unknown"
    case known = "known"
    case unknownWord = "unknownWord"   // 标记为不会
    case correct = "correct"           // 拼写正确
    case wrong = "wrong"               // 拼写错误
}

struct Word: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var phonetic: String
    var partOfSpeech: String
    var chineseMeaning: String
    var status: WordStatus
    var studyStage: Int  // 0=未学习 1=第一遍 2=第二遍 3=第三遍 4=已完成

    init(text: String, phonetic: String = "", partOfSpeech: String = "", chineseMeaning: String = "") {
        self.id = UUID()
        self.text = text
        self.phonetic = phonetic
        self.partOfSpeech = partOfSpeech
        self.chineseMeaning = chineseMeaning
        self.status = .unknown
        self.studyStage = 0
    }
}

struct StudySession: Identifiable, Codable {
    let id: UUID
    var words: [Word]
    var currentStage: Int  // 1=认词 2=判断 3=拼写
    var currentIndex: Int
    var startTime: Date
    var endTime: Date?
    var results: [UUID: Bool]  // wordId -> passed

    init(words: [Word]) {
        self.id = UUID()
        self.words = words
        self.currentStage = 1
        self.currentIndex = 0
        self.startTime = Date()
        self.endTime = nil
        self.results = [:]
    }

    var isCompleted: Bool {
        currentStage > 3
    }

    mutating func advanceStage() {
        currentIndex = 0
        currentStage += 1
    }

    mutating func nextWord() {
        currentIndex += 1
        if currentIndex >= currentWords.count {
            advanceStage()
        }
    }

    var currentWords: [Word] {
        switch currentStage {
        case 1:
            return words
        case 2:
            return words.filter { $0.status == .unknownWord || $0.status == .unknown }
        case 3:
            return words.filter { $0.status == .wrong }
        default:
            return []
        }
    }
}
