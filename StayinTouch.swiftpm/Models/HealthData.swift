import Foundation

struct HealthSnapshot {
    let heartRate: ClosedRange<Int>
    let heartStatus: HeartStatus
    let lastUpdated: Date
    
    enum HeartStatus: String {
        case resting = "Resting"
        case active = "Active"
        case sleeping = "Sleeping"
        case walking = "Walking"
    }
}

struct HeartbeatMessage: Identifiable {
    let id = UUID()
    let fromUserId: String
    let pattern: [Double] // Intervals between taps in seconds
    let timestamp: Date
}
