import Foundation

struct MockDataProvider {
    
    private static func dateBySubtracting(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0) -> Date {
        let components = DateComponents(year: -years, month: -months, day: -days, hour: -hours)
        return Calendar.current.date(byAdding: components, to: .now) ?? .now
    }
    
    // MARK: - Users
    
    static let me = User(
        id: "me",
        name: "Three",
        avatarEmoji: "🧑‍💻",
        location: Coordinate(latitude: 40.7128, longitude: -74.0060),
        locationName: "New York, USA",
        lastSeenDate: Date(),
        isOnline: true
    )
    
    static let mom = User(
        id: "mom",
        name: "Mom",
        avatarEmoji: "👩‍🦱",
        location: Coordinate(latitude: 23.1291, longitude: 113.2644),
        locationName: "Guangzhou, China",
        lastSeenDate: dateBySubtracting(hours: 1),
        isOnline: true
    )
    
    static let hayden = User(
        id: "hayden",
        name: "Hayden",
        avatarEmoji: "👨‍💻",
        location: Coordinate(latitude: 40.1164, longitude: -88.2434),
        locationName: "Champaign, Illinois, USA",
        lastSeenDate: dateBySubtracting(hours: 2),
        isOnline: true
    )
    
    static let grandpa = User(
        id: "grandpa",
        name: "Grandpa",
        avatarEmoji: "👴",
        location: Coordinate(latitude: 26.8932, longitude: 112.5719),
        locationName: "Hengyang, China",
        lastSeenDate: dateBySubtracting(years: 2, months: 6),
        isOnline: false
    )
    
    static let mg = User(
        id: "mg",
        name: "Mg",
        avatarEmoji: "👩",
        location: Coordinate(latitude: 51.5074, longitude: -0.1278),
        locationName: "London, UK",
        lastSeenDate: dateBySubtracting(years: 3),
        isOnline: false
    )
    
    static let tommy = User(
        id: "tommy",
        name: "Tommy",
        avatarEmoji: "👨‍🦱",
        location: Coordinate(latitude: 42.2626, longitude: -71.8023),
        locationName: "Worcester (Boston), USA",
        lastSeenDate: dateBySubtracting(hours: 2),
        isOnline: true
    )
    
    static let eric = User(
        id: "eric",
        name: "Eric",
        avatarEmoji: "👨",
        location: Coordinate(latitude: 32.7157, longitude: -117.1611),
        locationName: "San Diego, California, USA",
        lastSeenDate: dateBySubtracting(years: 1, months: 5),
        isOnline: false
    )

    static let mengxi = User(
        id: "mengxi",
        name: "Mengxi",
        avatarEmoji: "🧑",
        location: Coordinate(latitude: 41.8781, longitude: -87.6298),
        locationName: "Chicago, Illinois, USA",
        lastSeenDate: dateBySubtracting(hours: 1),
        isOnline: true
    )

    static let grandma = User(
        id: "grandma",
        name: "Grandma",
        avatarEmoji: "👵",
        location: Coordinate(latitude: 23.0215, longitude: 113.1214),
        locationName: "Foshan, Guangdong, China",
        lastSeenDate: dateBySubtracting(hours: 3),
        isOnline: true
    )

    static let songshu = User(
        id: "songshu",
        name: "Songshu",
        avatarEmoji: "🐿️",
        location: Coordinate(latitude: -37.8136, longitude: 144.9631),
        locationName: "Melbourne, Australia",
        lastSeenDate: dateBySubtracting(days: 5),
        isOnline: false
    )

    static let gege = User(
        id: "gege",
        name: "Brother",
        avatarEmoji: "👦",
        location: Coordinate(latitude: 23.1291, longitude: 113.3644),
        locationName: "Guangzhou, China",
        lastSeenDate: dateBySubtracting(years: 2, months: 5),
        isOnline: false
    )

    static let jiejie = User(
        id: "jiejie",
        name: "Sister",
        avatarEmoji: "👩‍🦰",
        location: Coordinate(latitude: 28.2282, longitude: 112.9388),
        locationName: "Changsha, China",
        lastSeenDate: dateBySubtracting(years: 2, months: 7),
        isOnline: false
    )
    
    static let allContacts: [User] = [mom, hayden, grandpa, grandma, mg, tommy, eric, mengxi, songshu, gege, jiejie]
    
    // MARK: - Mood
    
    static func moodFor(_ userId: String) -> MoodEntry {
        switch userId {
        case "mom":
            return MoodEntry(emoji: "☕️", label: "Cozy vibes",       activity: "At Home",        timestamp: Date().addingTimeInterval(-3600))
        case "hayden":
            return MoodEntry(emoji: "😌", label: "Feeling calm",     activity: "In Class",       timestamp: Date().addingTimeInterval(-1800))
        case "grandpa":
            return MoodEntry(emoji: "😊", label: "Feeling happy",    activity: "Morning Walk",   timestamp: Date().addingTimeInterval(-4200))
        case "mg":
            return MoodEntry(emoji: "📚", label: "Studying hard",    activity: "At Library",     timestamp: Date().addingTimeInterval(-2500))
        case "tommy":
            return MoodEntry(emoji: "💪", label: "Feeling proud",    activity: "After Gym",      timestamp: Date().addingTimeInterval(-3100))
        case "eric":
            return MoodEntry(emoji: "☕️", label: "Cozy vibes",       activity: "At Café",        timestamp: Date().addingTimeInterval(-2800))
        case "mengxi":
            return MoodEntry(emoji: "🧘", label: "Feeling centered", activity: "After Work",     timestamp: Date().addingTimeInterval(-2400))
        case "grandma":
            return MoodEntry(emoji: "🌸", label: "Feeling blessed",  activity: "Morning Tea",    timestamp: Date().addingTimeInterval(-1800))
        case "songshu":
            return MoodEntry(emoji: "✨", label: "Hyped up",         activity: "Watching Anime", timestamp: Date().addingTimeInterval(-2100))
        case "gege":
            return MoodEntry(emoji: "😴", label: "Need more sleep",  activity: "After Work",     timestamp: Date().addingTimeInterval(-5400))
        case "jiejie":
            return MoodEntry(emoji: "🍜", label: "Well-fed & happy", activity: "After Lunch",    timestamp: Date().addingTimeInterval(-2700))
        default:
            return MoodEntry(emoji: "💻", label: "In the zone",      activity: "Coding",         timestamp: Date())
        }
    }
    
    // MARK: - Health

    static func healthFor(_ userId: String) -> HealthSnapshot {
        switch userId {
        case "mom":
            return HealthSnapshot(heartRate: 76, heartStatus: .walking, sleepHours: 7.2, wristTemperature: 36.1, bloodOxygen: 98, hrv: 48, respiratoryRate: 15, lastUpdated: Date().addingTimeInterval(-1200))
        case "hayden":
            return HealthSnapshot(heartRate: 71, heartStatus: .resting, sleepHours: 6.0, wristTemperature: 35.8, bloodOxygen: 99, hrv: 62, respiratoryRate: 14, lastUpdated: Date().addingTimeInterval(-600))
        case "grandpa":
            return HealthSnapshot(heartRate: 68, heartStatus: .walking, sleepHours: 6.5, wristTemperature: 35.6, bloodOxygen: 96, hrv: 28, respiratoryRate: 16, lastUpdated: Date().addingTimeInterval(-1500))
        case "mg":
            return HealthSnapshot(heartRate: 74, heartStatus: .active, sleepHours: 7.8, wristTemperature: 36.0, bloodOxygen: 99, hrv: 55, respiratoryRate: 15, lastUpdated: Date().addingTimeInterval(-500))
        case "tommy":
            return HealthSnapshot(heartRate: 82, heartStatus: .active, sleepHours: 7.0, wristTemperature: 36.4, bloodOxygen: 98, hrv: 44, respiratoryRate: 17, lastUpdated: Date().addingTimeInterval(-450))
        case "eric":
            return HealthSnapshot(heartRate: 70, heartStatus: .resting, sleepHours: 8.2, wristTemperature: 35.9, bloodOxygen: 99, hrv: 68, respiratoryRate: 13, lastUpdated: Date().addingTimeInterval(-700))
        case "mengxi":
            return HealthSnapshot(heartRate: 72, heartStatus: .resting, sleepHours: 7.5, wristTemperature: 36.0, bloodOxygen: 98, hrv: 58, respiratoryRate: 14, lastUpdated: Date().addingTimeInterval(-520))
        case "grandma":
            return HealthSnapshot(heartRate: 71, heartStatus: .resting, sleepHours: 7.0, wristTemperature: 35.7, bloodOxygen: 95, hrv: 24, respiratoryRate: 16, lastUpdated: Date().addingTimeInterval(-900))
        case "songshu":
            return HealthSnapshot(heartRate: 77, heartStatus: .walking, sleepHours: 8.0, wristTemperature: 36.2, bloodOxygen: 99, hrv: 61, respiratoryRate: 15, lastUpdated: Date().addingTimeInterval(-600))
        case "gege":
            return HealthSnapshot(heartRate: 73, heartStatus: .resting, sleepHours: 6.2, wristTemperature: 36.0, bloodOxygen: 98, hrv: 42, respiratoryRate: 15, lastUpdated: Date().addingTimeInterval(-1800))
        case "jiejie":
            return HealthSnapshot(heartRate: 70, heartStatus: .resting, sleepHours: 7.4, wristTemperature: 35.9, bloodOxygen: 99, hrv: 54, respiratoryRate: 14, lastUpdated: Date().addingTimeInterval(-1200))
        default:
            return HealthSnapshot(heartRate: 74, heartStatus: .resting, sleepHours: 7.0, wristTemperature: 36.0, bloodOxygen: 98, hrv: 55, respiratoryRate: 14, lastUpdated: Date())
        }
    }
    
    // MARK: - Activity
    
    static func activityFor(_ userId: String) -> ActivitySnapshot {
        switch userId {
        case "mom":
            return ActivitySnapshot(moveCalories: 380, moveGoal: 500, exerciseMinutes: 25, exerciseGoal: 30, standHours: 7,  standGoal: 10, weeklyMoveTrend: [310, 350, 400, 330, 420, 360, 380])
        case "hayden":
            return ActivitySnapshot(moveCalories: 514, moveGoal: 600, exerciseMinutes: 12, exerciseGoal: 30, standHours: 9,  standGoal: 12, weeklyMoveTrend: [460, 490, 520, 480, 540, 500, 514])
        case "grandpa":
            return ActivitySnapshot(moveCalories: 260, moveGoal: 450, exerciseMinutes: 18, exerciseGoal: 30, standHours: 6,  standGoal: 10, weeklyMoveTrend: [200, 230, 250, 210, 270, 240, 260])
        case "mg":
            return ActivitySnapshot(moveCalories: 430, moveGoal: 600, exerciseMinutes: 20, exerciseGoal: 30, standHours: 8,  standGoal: 12, weeklyMoveTrend: [380, 410, 440, 400, 460, 420, 430])
        case "tommy":
            return ActivitySnapshot(moveCalories: 610, moveGoal: 700, exerciseMinutes: 28, exerciseGoal: 30, standHours: 10, standGoal: 12, weeklyMoveTrend: [560, 600, 620, 590, 650, 580, 610])
        case "eric":
            return ActivitySnapshot(moveCalories: 470, moveGoal: 650, exerciseMinutes: 22, exerciseGoal: 30, standHours: 9,  standGoal: 12, weeklyMoveTrend: [410, 440, 460, 430, 490, 450, 470])
        case "mengxi":
            return ActivitySnapshot(moveCalories: 455, moveGoal: 620, exerciseMinutes: 19, exerciseGoal: 30, standHours: 8,  standGoal: 12, weeklyMoveTrend: [390, 420, 445, 410, 470, 435, 455])
        case "grandma":
            return ActivitySnapshot(moveCalories: 290, moveGoal: 400, exerciseMinutes: 22, exerciseGoal: 30, standHours: 7,  standGoal: 10, weeklyMoveTrend: [240, 260, 280, 250, 300, 270, 290])
        case "songshu":
            return ActivitySnapshot(moveCalories: 530, moveGoal: 650, exerciseMinutes: 26, exerciseGoal: 30, standHours: 9,  standGoal: 12, weeklyMoveTrend: [470, 500, 520, 490, 550, 510, 530])
        case "gege":
            return ActivitySnapshot(moveCalories: 340, moveGoal: 500, exerciseMinutes: 14, exerciseGoal: 30, standHours: 7,  standGoal: 10, weeklyMoveTrend: [290, 310, 350, 300, 370, 330, 340])
        case "jiejie":
            return ActivitySnapshot(moveCalories: 420, moveGoal: 550, exerciseMinutes: 21, exerciseGoal: 30, standHours: 8,  standGoal: 10, weeklyMoveTrend: [360, 390, 410, 380, 440, 400, 420])
        default:
            return ActivitySnapshot(moveCalories: 420, moveGoal: 600, exerciseMinutes: 15, exerciseGoal: 30, standHours: 8,  standGoal: 12, weeklyMoveTrend: [310, 350, 420, 380, 450, 400, 420])
        }
    }
    
    // MARK: - Today Posts
    
    static func todayPostsFor(_ userId: String) -> [TodayPost] {
        switch userId {

        case "mom":
            return [TodayPost(userId: "mom", photoName: "photo_home_cooking",
                              caption: "Made your favorite tang yuan today 🥟 missing you",
                              timestamp: Date().addingTimeInterval(-5400), reactions: [])]

        case "hayden":
            return [TodayPost(userId: "hayden", photoName: "photo_campus",
                              caption: "Midterm week — sending prayers for everyone 📚",
                              timestamp: Date().addingTimeInterval(-3300), reactions: [])]

        case "grandpa":
            return []  // Demo: empty state — Grandpa hasn't shared anything today

        case "mg":
            return [TodayPost(userId: "mg", photoName: "photo_coffee",
                              caption: "Rainy London afternoon, coffee and deadlines ☕️",
                              timestamp: Date().addingTimeInterval(-3000), reactions: [])]

        case "tommy":
            return [TodayPost(userId: "tommy", photoName: "photo_park_bench",
                              caption: "Finally touched grass between back-to-back lectures 🌿",
                              timestamp: Date().addingTimeInterval(-4100), reactions: [])]

        case "eric":
            return [TodayPost(userId: "eric", photoName: "photo_flower",
                              caption: "72°F and zero clouds — San Diego does it again ☀️",
                              timestamp: Date().addingTimeInterval(-2600), reactions: [])]

        case "mengxi":
            return [TodayPost(userId: "mengxi", photoName: "photo_campus",
                              caption: "Chicago wind almost took my umbrella today 💨 worth it for the view",
                              timestamp: Date().addingTimeInterval(-2900), reactions: [])]

        case "grandma":
            return [TodayPost(userId: "grandma", photoName: "photo_home_cooking",
                              caption: "Made dumplings today and saved your share 🥟",
                              timestamp: Date().addingTimeInterval(-3600), reactions: [])]

        case "songshu":
            return [TodayPost(userId: "songshu", photoName: "photo_cherry_blossom",
                              caption: "New season ep 1 is absolutely insane!! Let's gooo (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧",
                              timestamp: Date().addingTimeInterval(-4500), reactions: [])]

        case "gege":
            return [TodayPost(userId: "gege", photoName: "photo_sunset",
                              caption: "Guangzhou evening sky, snapped on my commute home 🌆",
                              timestamp: Date().addingTimeInterval(-6000), reactions: [])]

        case "jiejie":
            return [TodayPost(userId: "jiejie", photoName: "photo_home_cooking",
                              caption: "Changsha stinky tofu — smells awful, tastes amazing. Another bowl today 😋",
                              timestamp: Date().addingTimeInterval(-4200), reactions: [])]

        default:
            // "me" — rich reactions (grouped: ❤️×3, 🔥×2, 🤗×1) + pre-seeded contact notes
            return [
                TodayPost(
                    userId: "me",
                    photoName: "photo_campus",
                    caption: "Late night coding session — NYC never sleeps either 🌃",
                    timestamp: Date().addingTimeInterval(-1800),
                    reactions: [
                        Reaction(emoji: "❤️", fromUserId: "mom",    fromUserEmoji: "👩‍🦱", timestamp: Date().addingTimeInterval(-1600)),
                        Reaction(emoji: "❤️", fromUserId: "hayden", fromUserEmoji: "👨‍💻", timestamp: Date().addingTimeInterval(-1400)),
                        Reaction(emoji: "❤️", fromUserId: "mengxi", fromUserEmoji: "🧑",   timestamp: Date().addingTimeInterval(-1200)),
                        Reaction(emoji: "🔥", fromUserId: "tommy",  fromUserEmoji: "👨‍🦱", timestamp: Date().addingTimeInterval(-1100)),
                        Reaction(emoji: "🔥", fromUserId: "eric",   fromUserEmoji: "👨",   timestamp: Date().addingTimeInterval(-1000)),
                        Reaction(emoji: "🤗", fromUserId: "songshu",fromUserEmoji: "🐿️",  timestamp: Date().addingTimeInterval(-900))
                    ],
                    notes: [
                        ContactNote(fromUserId: "mom",    fromUserName: "Mom",    fromUserEmoji: "👩‍🦱",
                                    text: "Don't forget to eat! Don't stay up too late 😢",
                                    timestamp: Date().addingTimeInterval(-800)),
                        ContactNote(fromUserId: "hayden", fromUserName: "Hayden", fromUserEmoji: "👨‍💻",
                                    text: "Same energy here bro, let's go 💪",
                                    timestamp: Date().addingTimeInterval(-700)),
                        ContactNote(fromUserId: "songshu",fromUserName: "Songshu",fromUserEmoji: "🐿️",
                                    text: "Grind mode!! Jealous you can pull all-nighters, I'm already dead (´-ω-`)",
                                    timestamp: Date().addingTimeInterval(-600)),
                        ContactNote(fromUserId: "tommy",  fromUserName: "Tommy",  fromUserEmoji: "👨‍🦱",
                                    text: "NYC grind hits different, respect 🫡",
                                    timestamp: Date().addingTimeInterval(-400))
                    ]
                ),
            ]
        }
    }
}
