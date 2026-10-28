//
//  WordStoreTests.swift
//  WordBoBo
//

import XCTest
@testable import WordBoBo

class WordStoreTests: XCTestCase {
    var sut: WordStore!

    override func setUp() {
        super.setUp()
        sut = WordStore.shared
        // Clear any existing data
        sut.allWords = []
        sut.completedSessions = []
        sut.studyHistory = [:]
    }

    func testParseSimpleWords() {
        let text = """
        apple /ˈæpl/ n. 苹果
        banana /bəˈnænə/ n. 香蕉
        cat /kæt/ n. 猫
        """

        let words = sut.parseWords(from: text)
        XCTAssertEqual(words.count, 3)
        XCTAssertEqual(words[0].text, "apple")
        XCTAssertEqual(words[0].chineseMeaning, "苹果")
    }

    func testParseWordsWithoutPhonetic() {
        let text = "hello n. 你好\nworld v. 世界"

        let words = sut.parseWords(from: text)
        XCTAssertEqual(words.count, 2)
        XCTAssertEqual(words[0].text, "hello")
    }

    func testParseWordsTabSeparated() {
        let text = "abandon\t放弃\nability\t能力"

        let words = sut.parseWords(from: text)
        XCTAssertEqual(words.count, 2)
        XCTAssertEqual(words[0].text, "abandon")
    }

    func testDuplicateWordsRemoved() {
        let text = "apple n. 苹果\napple n. 苹果"

        let words = sut.parseWords(from: text)
        XCTAssertEqual(words.count, 1)
    }

    func testEmptyLinesSkipped() {
        let text = """

        apple n. 苹果

        banana n. 香蕉

        """

        let words = sut.parseWords(from: text)
        XCTAssertEqual(words.count, 2)
    }

    func testWordInitialStatus() {
        let word = Word(text: "test", phonetic: "/test/", partOfSpeech: "n.", chineseMeaning: "测试")
        XCTAssertEqual(word.status, .unknown)
        XCTAssertEqual(word.studyStage, 0)
    }

    func testStudySessionCreation() {
        let words = [
            Word(text: "hello", chineseMeaning: "你好"),
            Word(text: "world", chineseMeaning: "世界")
        ]
        let session = StudySession(words: words)
        XCTAssertEqual(session.words.count, 2)
        XCTAssertEqual(session.currentStage, 1)
        XCTAssertEqual(session.currentIndex, 0)
        XCTAssertFalse(session.isCompleted)
    }

    func testSessionAdvanceStage() {
        let words = [Word(text: "hello", chineseMeaning: "你好")]
        var session = StudySession(words: words)
        session.advanceStage()
        XCTAssertEqual(session.currentStage, 2)
        XCTAssertEqual(session.currentIndex, 0)
    }
}
