import Foundation

struct MoodEntry: Identifiable {
    let id = UUID()
    let emoji: String
    let label: String
    let activity: String
    let timestamp: Date
}

enum MoodOption: String, CaseIterable, Identifiable {
    case calm = "😌"
    case happy = "😊"
    case excited = "🤩"
    case studying = "📚"
    case tired = "😴"
    case stressed = "😰"
    case cozy = "☕️"
    case proud = "💪"
    case missing = "🥺"
    case loved = "🥰"
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .calm: "Feeling calm"
        case .happy: "Feeling happy"
        case .excited: "Feeling excited"
        case .studying: "Studying hard"
        case .tired: "Feeling tired"
        case .stressed: "Feeling stressed"
        case .cozy: "Cozy vibes"
        case .proud: "Feeling proud"
        case .missing: "Missing you"
        case .loved: "Feeling loved"
        }
    }
    
    var activity: String {
        switch self {
        case .calm: "In Class"
        case .happy: "Free Time"
        case .excited: "Out & About"
        case .studying: "At Library"
        case .tired: "At Home"
        case .stressed: "Exam Week"
        case .cozy: "At Café"
        case .proud: "After Gym"
        case .missing: "At Home"
        case .loved: "With Friends"
        }
    }
}
