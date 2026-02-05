//
//  QuizHistoryManager.swift
//  PersonalityQuiz
//

import Foundation

class QuizHistoryManager {
    
    static let shared = QuizHistoryManager()
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "quizHistory"
    
    struct QuizResult: Codable {
        let quizIdentifier: String
        let quizTitle: String
        let result: String
        let resultEmoji: String
        let resultDescription: String
        let date: Date
        let timeTaken: TimeInterval // in seconds
        
        var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        
        var formattedTime: String {
            let minutes = Int(timeTaken) / 60
            let seconds = Int(timeTaken) % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private init() {}
    
    // MARK: - Save Result
    func saveQuizResult(
        quizIdentifier: String,
        quizTitle: String,
        result: String,
        resultEmoji: String,
        resultDescription: String,
        timeTaken: TimeInterval
    ) {
        var history = getHistory()
        
        let newResult = QuizResult(
            quizIdentifier: quizIdentifier,
            quizTitle: quizTitle,
            result: result,
            resultEmoji: resultEmoji,
            resultDescription: resultDescription,
            date: Date(),
            timeTaken: timeTaken
        )
        
        history.append(newResult)
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(history) {
            userDefaults.set(encoded, forKey: historyKey)
        }
    }
    
    // MARK: - Get History
    func getHistory() -> [QuizResult] {
        guard let data = userDefaults.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([QuizResult].self, from: data) else {
            return []
        }
        return history.sorted { $0.date > $1.date } // Most recent first
    }
    
    // MARK: - Check if Quiz Completed
    func hasCompletedQuiz(identifier: String) -> Bool {
        let history = getHistory()
        return history.contains { $0.quizIdentifier == identifier }
    }
    
    // MARK: - Get Last Result for Quiz
    func getLastResult(for identifier: String) -> QuizResult? {
        let history = getHistory()
        return history.first { $0.quizIdentifier == identifier }
    }
    
    // MARK: - Clear History
    func clearHistory() {
        userDefaults.removeObject(forKey: historyKey)
    }
    
    // MARK: - Delete Specific Result
    func deleteResult(at index: Int) {
        var history = getHistory()
        guard index < history.count else { return }
        history.remove(at: index)
        
        if let encoded = try? JSONEncoder().encode(history) {
            userDefaults.set(encoded, forKey: historyKey)
        }
    }
    
    // MARK: - Statistics
    func getStatistics() -> (totalQuizzes: Int, uniqueQuizzes: Int, totalTime: TimeInterval) {
        let history = getHistory()
        let uniqueQuizzes = Set(history.map { $0.quizIdentifier }).count
        let totalTime = history.reduce(0) { $0 + $1.timeTaken }
        return (history.count, uniqueQuizzes, totalTime)
    }
}
