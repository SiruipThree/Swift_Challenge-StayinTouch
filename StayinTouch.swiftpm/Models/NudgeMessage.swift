import Foundation

struct NudgeMessage: Identifiable {
    let id = UUID()
    let fromUserId: String
    let toUserId: String
    let timestamp: Date
}
