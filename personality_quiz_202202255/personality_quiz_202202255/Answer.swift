//
//  Answer.swift
//  PersonalityQuiz
//

import Foundation

struct Answer {
    var text: String
    var type: AnswerType
}

enum AnswerType {
    case major(MajorType)
    case animal(AnimalType)
    
    // Convenience getters
    var majorType: MajorType? {
        if case .major(let type) = self {
            return type
        }
        return nil
    }
    
    var animalType: AnimalType? {
        if case .animal(let type) = self {
            return type
        }
        return nil
    }
}

// MARK: - Major Types
enum MajorType: String {
    case business = "💼"
    case engineering = "⚙️"
    case arts = "🎨"
    case science = "🔬"
    
    var definition: String {
        switch self {
        case .business:
            return "You have strong leadership skills and enjoy working with people. You're goal-oriented and thrive in dynamic environments where you can make strategic decisions."
        case .engineering:
            return "You're analytical and love solving complex problems. You enjoy understanding how things work and creating practical solutions to real-world challenges."
        case .arts:
            return "You're creative and expressive, with a passion for storytelling and design. You see the world through a unique lens and enjoy bringing ideas to life."
        case .science:
            return "You're curious and methodical, driven by a desire to understand the natural world. You excel at research and discovery, always asking 'why' and 'how'."
        }
    }
    
    var fullName: String {
        switch self {
        case .business:
            return "Business & Management"
        case .engineering:
            return "Engineering & Technology"
        case .arts:
            return "Arts & Humanities"
        case .science:
            return "Science & Research"
        }
    }
}

// MARK: - Animal Types
enum AnimalType: Character {
    case lion = "🦁"
    case cat = "🐱"
    case rabbit = "🐰"
    case turtle = "🐢"
    
    var definition: String {
        switch self {
        case .lion:
            return "You are incredibly outgoing. You surround yourself with the people you love and enjoy activities with your friends."
        case .cat:
            return "Mischievous, yet mild-tempered, you enjoy doing things on your own terms."
        case .rabbit:
            return "You love everything that's soft. You are healthy and full of energy."
        case .turtle:
            return "You are wise beyond your years, and you focus on the details. Slow and steady wins the race."
        }
    }
    
    var fullName: String {
        switch self {
        case .lion:
            return "Lion"
        case .cat:
            return "Cat"
        case .rabbit:
            return "Rabbit"
        case .turtle:
            return "Turtle"
        }
    }
}

// MARK: - Convenience Initializers for backward compatibility
extension Answer {
    init(text: String, type: MajorType) {
        self.text = text
        self.type = .major(type)
    }
    
    init(text: String, type: AnimalType) {
        self.text = text
        self.type = .animal(type)
    }
}
