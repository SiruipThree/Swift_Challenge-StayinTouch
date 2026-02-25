import Foundation

struct ActivitySnapshot {
    let moveCalories: Int
    let moveGoal: Int
    let exerciseMinutes: Int
    let exerciseGoal: Int
    let standHours: Int
    let standGoal: Int
    
    var moveProgress: Double { Double(moveCalories) / Double(moveGoal) }
    var exerciseProgress: Double { Double(exerciseMinutes) / Double(exerciseGoal) }
    var standProgress: Double { Double(standHours) / Double(standGoal) }
}

struct Encouragement: Identifiable {
    let id = UUID()
    let message: String
    let emoji: String
    let fromUserId: String
    let timestamp: Date
}

enum EncouragementOption: CaseIterable, Identifiable {
    case keepGoing
    case amazing
    case together
    case proud
    case challenge
    
    var id: String { emoji }
    
    var message: String {
        switch self {
        case .keepGoing: "Keep going!"
        case .amazing: "You're doing amazing!"
        case .together: "Let's move together!"
        case .proud: "So proud of you!"
        case .challenge: "8,000 steps today?"
        }
    }
    
    var emoji: String {
        switch self {
        case .keepGoing: "💪"
        case .amazing: "🌟"
        case .together: "🏃‍♂️"
        case .proud: "🥰"
        case .challenge: "🎯"
        }
    }
}
