import Foundation

struct MockDataProvider {
    
    // MARK: - Users
    
    static let me = User(
        id: "me",
        name: "Junyi",
        avatarEmoji: "🧑‍💻",
        location: Coordinate(latitude: 40.7128, longitude: -74.0060), // New York
        locationName: "New York, USA",
        lastSeenDate: Date(),
        isOnline: true
    )
    
    static let linda = User(
        id: "linda",
        name: "Linda",
        avatarEmoji: "👩",
        location: Coordinate(latitude: 31.2304, longitude: 121.4737), // Shanghai
        locationName: "Shanghai, China",
        lastSeenDate: Calendar.current.date(byAdding: .day, value: -129, to: .now)!,
        isOnline: true
    )
    
    static let mom = User(
        id: "mom",
        name: "Mom",
        avatarEmoji: "👩‍🦱",
        location: Coordinate(latitude: 31.2304, longitude: 121.4737), // Shanghai
        locationName: "Shanghai, China",
        lastSeenDate: Calendar.current.date(byAdding: .day, value: -129, to: .now)!,
        isOnline: false
    )
    
    static let allContacts: [User] = [linda, mom]
    
    // MARK: - Mood
    
    static func moodFor(_ userId: String) -> MoodEntry {
        switch userId {
        case "linda":
            return MoodEntry(
                emoji: "😌",
                label: "Feeling calm",
                activity: "In Class",
                timestamp: Date().addingTimeInterval(-1800)
            )
        case "mom":
            return MoodEntry(
                emoji: "☕️",
                label: "Cozy vibes",
                activity: "At Home",
                timestamp: Date().addingTimeInterval(-3600)
            )
        default:
            return MoodEntry(
                emoji: "📚",
                label: "Studying hard",
                activity: "At Library",
                timestamp: Date()
            )
        }
    }
    
    // MARK: - Health
    
    static func healthFor(_ userId: String) -> HealthSnapshot {
        switch userId {
        case "linda":
            return HealthSnapshot(
                heartRate: 67...75,
                heartStatus: .resting,
                lastUpdated: Date().addingTimeInterval(-600)
            )
        case "mom":
            return HealthSnapshot(
                heartRate: 72...80,
                heartStatus: .walking,
                lastUpdated: Date().addingTimeInterval(-1200)
            )
        default:
            return HealthSnapshot(
                heartRate: 70...78,
                heartStatus: .resting,
                lastUpdated: Date()
            )
        }
    }
    
    // MARK: - Activity
    
    static func activityFor(_ userId: String) -> ActivitySnapshot {
        switch userId {
        case "linda":
            return ActivitySnapshot(
                moveCalories: 514, moveGoal: 600,
                exerciseMinutes: 12, exerciseGoal: 30,
                standHours: 9, standGoal: 12
            )
        case "mom":
            return ActivitySnapshot(
                moveCalories: 380, moveGoal: 500,
                exerciseMinutes: 25, exerciseGoal: 30,
                standHours: 7, standGoal: 10
            )
        default:
            return ActivitySnapshot(
                moveCalories: 420, moveGoal: 600,
                exerciseMinutes: 15, exerciseGoal: 30,
                standHours: 8, standGoal: 12
            )
        }
    }
    
    // MARK: - Today Posts
    
    static func todayPostsFor(_ userId: String) -> [TodayPost] {
        switch userId {
        case "linda":
            return [
                TodayPost(
                    userId: "linda",
                    photoName: "photo_cherry_blossom",
                    caption: "Spring is here!",
                    timestamp: Date().addingTimeInterval(-3600),
                    reactions: []
                ),
                TodayPost(
                    userId: "linda",
                    photoName: "photo_park_bench",
                    caption: "Peaceful afternoon",
                    timestamp: Date().addingTimeInterval(-7200),
                    reactions: []
                ),
                TodayPost(
                    userId: "linda",
                    photoName: "photo_flower",
                    caption: "Found these on my walk",
                    timestamp: Date().addingTimeInterval(-10800),
                    reactions: []
                )
            ]
        case "mom":
            return [
                TodayPost(
                    userId: "mom",
                    photoName: "photo_home_cooking",
                    caption: "Made your favorite today 🥟",
                    timestamp: Date().addingTimeInterval(-5400),
                    reactions: []
                ),
                TodayPost(
                    userId: "mom",
                    photoName: "photo_sunset",
                    caption: "Beautiful evening",
                    timestamp: Date().addingTimeInterval(-9000),
                    reactions: []
                )
            ]
        default:
            return [
                TodayPost(
                    userId: "me",
                    photoName: "photo_campus",
                    caption: "Study grind never stops",
                    timestamp: Date().addingTimeInterval(-1800),
                    reactions: []
                ),
                TodayPost(
                    userId: "me",
                    photoName: "photo_coffee",
                    caption: "Fuel for finals ☕",
                    timestamp: Date().addingTimeInterval(-5400),
                    reactions: []
                )
            ]
        }
    }
}
