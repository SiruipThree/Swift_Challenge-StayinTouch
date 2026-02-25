import Foundation

struct TodayPost: Identifiable {
    let id = UUID()
    let userId: String
    let photoName: String  // local asset name
    let caption: String
    let timestamp: Date
    var reactions: [Reaction]
}

struct Reaction: Identifiable {
    let id = UUID()
    let emoji: String
    let fromUserId: String
    let timestamp: Date
}

enum ReactionOption: String, CaseIterable, Identifiable {
    case heart = "❤️"
    case hug = "🤗"
    case tearSmile = "🥲"
    case starEyes = "😍"
    case clap = "👏"
    case fire = "🔥"
    
    var id: String { rawValue }
}
