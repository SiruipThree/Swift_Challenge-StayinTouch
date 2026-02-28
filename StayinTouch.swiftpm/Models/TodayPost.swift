import Foundation

struct TodayPost: Identifiable {
    let id = UUID()
    let userId: String
    let photoName: String  // local asset name, ignored when imageData is set
    /// Raw image data from the photo library. When present, rendered directly.
    var imageData: Data? = nil
    let caption: String
    let timestamp: Date
    var reactions: [Reaction]
    /// Pre-seeded text notes left by contacts (read-only, from mock data).
    var notes: [ContactNote] = []
}

struct Reaction: Identifiable {
    let id = UUID()
    let emoji: String
    let fromUserId: String
    /// Emoji avatar of the sender — used in grouped reaction pills.
    var fromUserEmoji: String = ""
    let timestamp: Date
}

/// A text note left on a Today post by a contact.
struct ContactNote: Identifiable {
    let id = UUID()
    let fromUserId: String
    let fromUserName: String
    let fromUserEmoji: String
    let text: String
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
