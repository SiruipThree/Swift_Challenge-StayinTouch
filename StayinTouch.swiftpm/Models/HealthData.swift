import Foundation

struct HealthSnapshot {
    let heartRate: Int                  // BPM (most recent sample)
    let heartStatus: HeartStatus
    let sleepHours: Double              // last night's sleep in hours
    let wristTemperature: Double        // °C, typical 34.5–37.0
    let bloodOxygen: Int                // SpO₂ %, typical 95–100
    let hrv: Int                        // heart rate variability in ms, typical 20–90
    let respiratoryRate: Int            // breaths per minute, typical 12–20
    let lastUpdated: Date

    enum HeartStatus: String {
        case resting  = "Resting"
        case active   = "Active"
        case sleeping = "Sleeping"
        case walking  = "Walking"
    }
}

struct HeartbeatMessage: Identifiable {
    let id = UUID()
    let fromUserId: String
    let pattern: [Double]
    let timestamp: Date
}
