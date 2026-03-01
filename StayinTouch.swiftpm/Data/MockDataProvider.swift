import Foundation

struct MockDataProvider {
    
    private static func dateBySubtracting(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0) -> Date {
        let components = DateComponents(year: -years, month: -months, day: -days, hour: -hours)
        return Calendar.current.date(byAdding: components, to: .now) ?? .now
    }

    private static func loadPostImage(_ name: String) -> Data? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "jpg") else { return nil }
        return try? Data(contentsOf: url)
    }
    
    // MARK: - Users
    
    static let me = User(
        id: "me",
        name: "Three",
        avatarEmoji: "😎",
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
        lastSeenDate: dateBySubtracting(days: 562),
        isOnline: true
    )

    static let dad = User(
        id: "dad",
        name: "Dad",
        avatarEmoji: "👨‍🦳",
        location: Coordinate(latitude: 23.1291, longitude: 113.2644),
        locationName: "Guangzhou, China",
        lastSeenDate: dateBySubtracting(days: 562),
        isOnline: false
    )
    
    static let hayden = User(
        id: "hayden",
        name: "Hayden",
        avatarEmoji: "👨‍💻",
        location: Coordinate(latitude: 40.1164, longitude: -88.2434),
        locationName: "Champaign, Illinois, USA",
        lastSeenDate: dateBySubtracting(days: 15),
        isOnline: true
    )
    
    static let grandpa = User(
        id: "grandpa",
        name: "Grandpa",
        avatarEmoji: "👴",
        location: Coordinate(latitude: 26.8932, longitude: 112.5719),
        locationName: "Hengyang, China",
        lastSeenDate: dateBySubtracting(days: 577),
        isOnline: false
    )
    
    static let grandmaLong = User(
        id: "grandmaLong",
        name: "Grandma Long",
        avatarEmoji: "👵🏻",
        location: Coordinate(latitude: 26.8932, longitude: 112.5719),
        locationName: "Hengyang, China",
        lastSeenDate: dateBySubtracting(days: 576),
        isOnline: false,
        isMemorial: true
    )

    static let mg = User(
        id: "mg",
        name: "Mg",
        avatarEmoji: "👩",
        location: Coordinate(latitude: 51.5074, longitude: -0.1278),
        locationName: "London, UK",
        lastSeenDate: dateBySubtracting(months: 9),
        isOnline: false
    )
    
    static let tommy = User(
        id: "tommy",
        name: "Tommy",
        avatarEmoji: "👨‍🦱",
        location: Coordinate(latitude: 42.2626, longitude: -71.8023),
        locationName: "Worcester (Boston), USA",
        lastSeenDate: dateBySubtracting(months: 4),
        isOnline: true
    )
    
    static let eric = User(
        id: "eric",
        name: "Eric",
        avatarEmoji: "👨",
        location: Coordinate(latitude: 32.7157, longitude: -117.1611),
        locationName: "San Diego, California, USA",
        lastSeenDate: dateBySubtracting(months: 5),
        isOnline: false
    )

    static let mengxi = User(
        id: "mengxi",
        name: "Mengxi",
        avatarEmoji: "🧑",
        location: Coordinate(latitude: 41.8781, longitude: -87.6298),
        locationName: "Chicago, Illinois, USA",
        lastSeenDate: dateBySubtracting(days: 89),
        isOnline: true
    )

    static let grandma = User(
        id: "grandma",
        name: "Grandma",
        avatarEmoji: "👵",
        location: Coordinate(latitude: 23.0215, longitude: 113.1214),
        locationName: "Foshan, Guangdong, China",
        lastSeenDate: dateBySubtracting(days: 562),
        isOnline: true
    )

    static let songshu = User(
        id: "songshu",
        name: "Songshu",
        avatarEmoji: "🐿️",
        location: Coordinate(latitude: -37.8136, longitude: 144.9631),
        locationName: "Melbourne, Australia",
        lastSeenDate: dateBySubtracting(days: 634),
        isOnline: false
    )

    static let gege = User(
        id: "gege",
        name: "Brother",
        avatarEmoji: "👦",
        location: Coordinate(latitude: 23.1291, longitude: 113.3644),
        locationName: "Guangzhou, China",
        lastSeenDate: dateBySubtracting(days: 559),
        isOnline: false
    )

    static let jiejie = User(
        id: "jiejie",
        name: "Sister",
        avatarEmoji: "👩‍🦰",
        location: Coordinate(latitude: 28.2282, longitude: 112.9388),
        locationName: "Changsha, China",
        lastSeenDate: dateBySubtracting(days: 600),
        isOnline: false
    )
    
    static let allContacts: [User] = [mom, dad, grandmaLong, hayden, grandpa, grandma, mg, tommy, eric, mengxi, songshu, gege, jiejie]
    
    // MARK: - Mood
    
    static func moodFor(_ userId: String) -> MoodEntry {
        switch userId {
        case "mom":
            return MoodEntry(emoji: "☕️", label: "Cozy vibes",       activity: "At Home",        timestamp: Date().addingTimeInterval(-3600))
        case "dad":
            return MoodEntry(emoji: "🍵", label: "Winding down",     activity: "At Home",        timestamp: Date().addingTimeInterval(-7200))
        case "hayden":
            return MoodEntry(emoji: "😌", label: "Feeling calm",     activity: "In Class",       timestamp: Date().addingTimeInterval(-1800))
        case "grandpa":
            return MoodEntry(emoji: "📺", label: "Happy",            activity: "At Home",        timestamp: Date().addingTimeInterval(-4200))
        case "grandmaLong":
            return MoodEntry(emoji: "🤍", label: "Always with you",  activity: "",                timestamp: Date().addingTimeInterval(-5000))
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
        // 11 PM Guangzhou — sleeping, middle-aged woman
        case "mom":
            return HealthSnapshot(heartRate: 62, heartStatus: .resting, sleepHours: 7.2, wristTemperature: 36.1, bloodOxygen: 97, hrv: 42, respiratoryRate: 14, lastUpdated: Date().addingTimeInterval(-1200))
        // 11 PM Guangzhou — sleeping, middle-aged man
        case "dad":
            return HealthSnapshot(heartRate: 58, heartStatus: .resting, sleepHours: 6.8, wristTemperature: 36.2, bloodOxygen: 97, hrv: 35, respiratoryRate: 14, lastUpdated: Date().addingTimeInterval(-3600))
        // 9 AM Champaign — walking to class, young male
        case "hayden":
            return HealthSnapshot(heartRate: 88, heartStatus: .walking, sleepHours: 6.0, wristTemperature: 35.8, bloodOxygen: 99, hrv: 62, respiratoryRate: 16, lastUpdated: Date().addingTimeInterval(-120))
        // 11 PM Hengyang — sleeping, elderly man
        case "grandpa":
            return HealthSnapshot(heartRate: 56, heartStatus: .resting, sleepHours: 6.5, wristTemperature: 35.6, bloodOxygen: 95, hrv: 22, respiratoryRate: 15, lastUpdated: Date().addingTimeInterval(-1500))
        case "grandmaLong":
            return HealthSnapshot(heartRate: 70, heartStatus: .resting, sleepHours: 7.2, wristTemperature: 35.8, bloodOxygen: 96, hrv: 26, respiratoryRate: 16, lastUpdated: Date().addingTimeInterval(-1400))
        // 3 PM London — afternoon, young woman
        case "mg":
            return HealthSnapshot(heartRate: 78, heartStatus: .walking, sleepHours: 7.8, wristTemperature: 36.0, bloodOxygen: 99, hrv: 55, respiratoryRate: 15, lastUpdated: Date().addingTimeInterval(-180))
        // 10 AM Boston — morning gym, young male
        case "tommy":
            return HealthSnapshot(heartRate: 112, heartStatus: .active, sleepHours: 7.0, wristTemperature: 36.6, bloodOxygen: 98, hrv: 44, respiratoryRate: 22, lastUpdated: Date().addingTimeInterval(-60))
        // 7 AM San Diego — just woke up, young male
        case "eric":
            return HealthSnapshot(heartRate: 64, heartStatus: .resting, sleepHours: 8.2, wristTemperature: 35.9, bloodOxygen: 99, hrv: 68, respiratoryRate: 13, lastUpdated: Date().addingTimeInterval(-300))
        // 9 AM Chicago — commuting, young person
        case "mengxi":
            return HealthSnapshot(heartRate: 82, heartStatus: .walking, sleepHours: 7.5, wristTemperature: 36.0, bloodOxygen: 98, hrv: 58, respiratoryRate: 15, lastUpdated: Date().addingTimeInterval(-150))
        // 11 PM Foshan — sleeping, elderly woman
        case "grandma":
            return HealthSnapshot(heartRate: 58, heartStatus: .resting, sleepHours: 7.0, wristTemperature: 35.7, bloodOxygen: 95, hrv: 20, respiratoryRate: 15, lastUpdated: Date().addingTimeInterval(-900))
        // 2 AM Melbourne — deep sleep, young person
        case "songshu":
            return HealthSnapshot(heartRate: 52, heartStatus: .resting, sleepHours: 4.5, wristTemperature: 36.0, bloodOxygen: 99, hrv: 65, respiratoryRate: 12, lastUpdated: Date().addingTimeInterval(-600))
        // 11 PM Guangzhou — sleeping, young male
        case "gege":
            return HealthSnapshot(heartRate: 60, heartStatus: .resting, sleepHours: 6.2, wristTemperature: 36.0, bloodOxygen: 98, hrv: 48, respiratoryRate: 14, lastUpdated: Date().addingTimeInterval(-1800))
        // 11 PM Changsha — sleeping, young woman
        case "jiejie":
            return HealthSnapshot(heartRate: 59, heartStatus: .resting, sleepHours: 7.4, wristTemperature: 35.9, bloodOxygen: 99, hrv: 54, respiratoryRate: 13, lastUpdated: Date().addingTimeInterval(-1200))
        // 10 AM New York — morning, young male
        default:
            return HealthSnapshot(heartRate: 76, heartStatus: .walking, sleepHours: 7.0, wristTemperature: 36.0, bloodOxygen: 98, hrv: 55, respiratoryRate: 15, lastUpdated: Date())
        }
    }
    
    // MARK: - Activity
    
    static func activityFor(_ userId: String) -> ActivitySnapshot {
        switch userId {
        // 11 PM — full day done, middle-aged woman, moderate activity
        case "mom":
            return ActivitySnapshot(moveCalories: 420, moveGoal: 500, exerciseMinutes: 28, exerciseGoal: 30, standHours: 9,  standGoal: 10, weeklyMoveTrend: [380, 410, 450, 390, 470, 430, 420])
        // 11 PM — full day done, middle-aged man, less active
        case "dad":
            return ActivitySnapshot(moveCalories: 340, moveGoal: 450, exerciseMinutes: 15, exerciseGoal: 30, standHours: 8,  standGoal: 10, weeklyMoveTrend: [300, 320, 350, 280, 370, 330, 340])
        // 9 AM — just started the day, young male student
        case "hayden":
            return ActivitySnapshot(moveCalories: 85,  moveGoal: 600, exerciseMinutes: 5,  exerciseGoal: 30, standHours: 2,  standGoal: 12, weeklyMoveTrend: [520, 480, 560, 510, 540, 490, 85])
        // 11 PM — full day done, elderly man, low activity
        case "grandpa":
            return ActivitySnapshot(moveCalories: 280, moveGoal: 400, exerciseMinutes: 20, exerciseGoal: 30, standHours: 7,  standGoal: 10, weeklyMoveTrend: [220, 250, 270, 230, 290, 260, 280])
        case "grandmaLong":
            return ActivitySnapshot(moveCalories: 400, moveGoal: 400, exerciseMinutes: 30, exerciseGoal: 30, standHours: 10, standGoal: 10, weeklyMoveTrend: [400, 400, 400, 400, 400, 400, 400])
        // 3 PM — afternoon, young woman, good progress
        case "mg":
            return ActivitySnapshot(moveCalories: 350, moveGoal: 550, exerciseMinutes: 18, exerciseGoal: 30, standHours: 7,  standGoal: 12, weeklyMoveTrend: [420, 460, 490, 440, 510, 470, 350])
        // 10 AM — morning gym done, young active male
        case "tommy":
            return ActivitySnapshot(moveCalories: 320, moveGoal: 700, exerciseMinutes: 25, exerciseGoal: 30, standHours: 4,  standGoal: 12, weeklyMoveTrend: [620, 580, 660, 600, 640, 590, 320])
        // 7 AM — barely started, young male
        case "eric":
            return ActivitySnapshot(moveCalories: 30,  moveGoal: 600, exerciseMinutes: 0,  exerciseGoal: 30, standHours: 1,  standGoal: 12, weeklyMoveTrend: [450, 480, 520, 460, 500, 470, 30])
        // 9 AM — commuting, young person
        case "mengxi":
            return ActivitySnapshot(moveCalories: 110, moveGoal: 550, exerciseMinutes: 8,  exerciseGoal: 30, standHours: 2,  standGoal: 12, weeklyMoveTrend: [420, 450, 480, 430, 490, 460, 110])
        // 11 PM — full day done, elderly woman, light activity
        case "grandma":
            return ActivitySnapshot(moveCalories: 310, moveGoal: 400, exerciseMinutes: 24, exerciseGoal: 30, standHours: 8,  standGoal: 10, weeklyMoveTrend: [260, 280, 310, 270, 320, 290, 310])
        // 2 AM — deep sleep, yesterday's data complete, young person
        case "songshu":
            return ActivitySnapshot(moveCalories: 15,  moveGoal: 600, exerciseMinutes: 0,  exerciseGoal: 30, standHours: 0,  standGoal: 12, weeklyMoveTrend: [510, 540, 570, 520, 560, 530, 15])
        // 11 PM — full day done, young male, office worker
        case "gege":
            return ActivitySnapshot(moveCalories: 380, moveGoal: 500, exerciseMinutes: 12, exerciseGoal: 30, standHours: 8,  standGoal: 10, weeklyMoveTrend: [310, 340, 370, 320, 390, 350, 380])
        // 11 PM — full day done, young woman
        case "jiejie":
            return ActivitySnapshot(moveCalories: 460, moveGoal: 550, exerciseMinutes: 22, exerciseGoal: 30, standHours: 9,  standGoal: 10, weeklyMoveTrend: [400, 430, 460, 410, 480, 440, 460])
        // 10 AM — morning walk done, young male
        default:
            return ActivitySnapshot(moveCalories: 150, moveGoal: 600, exerciseMinutes: 12, exerciseGoal: 30, standHours: 3,  standGoal: 12, weeklyMoveTrend: [380, 420, 460, 400, 470, 430, 150])
        }
    }
    
    // MARK: - Today Posts
    
    static func todayPostsFor(_ userId: String) -> [TodayPost] {
        switch userId {

        case "mom":
            return [TodayPost(userId: "mom", photoName: "photo_home_cooking",
                              caption: "Another busy day, time to go exercise! 💪🏃‍♀️",
                              timestamp: Date().addingTimeInterval(-5400), reactions: [])]

        case "hayden":
            return [TodayPost(userId: "hayden", photoName: "photo_campus",
                              imageData: loadPostImage("post_hayden"),
                              caption: "Pittsburgh is so beautiful! Gotta come back here for another trip 🌉✨",
                              timestamp: Date().addingTimeInterval(-3300), reactions: [])]

        case "dad":
            return []

        case "grandmaLong":
            return []

        case "grandpa":
            return []

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
                              imageData: loadPostImage("post_mengxi"),
                              caption: "Since when is gas this cheap in Chicago?? 😳⛽",
                              timestamp: Date().addingTimeInterval(-2900), reactions: [])]

        case "grandma":
            return [TodayPost(userId: "grandma", photoName: "photo_home_cooking",
                              imageData: loadPostImage("post_grandma"),
                              caption: "The flowers look so pretty today! 🌸🌺",
                              timestamp: Date().addingTimeInterval(-3600), reactions: [])]

        case "songshu":
            return [TodayPost(userId: "songshu", photoName: "photo_cherry_blossom",
                              caption: "New season ep 1 is absolutely insane!! Let's gooo (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧",
                              timestamp: Date().addingTimeInterval(-4500), reactions: [])]

        case "gege":
            return [TodayPost(userId: "gege", photoName: "photo_sunset",
                              imageData: loadPostImage("post_brother"),
                              caption: "Absolutely stunning!! 🏔️😍",
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
                    imageData: loadPostImage("post_me"),
                    caption: "Late night coding session, NYC never sleeps either 🌃",
                    timestamp: Date().addingTimeInterval(-1800),
                    reactions: [
                        Reaction(emoji: "❤️", fromUserId: "mom",    fromUserEmoji: "👩‍🦱", timestamp: Date().addingTimeInterval(-1600)),
                        Reaction(emoji: "❤️", fromUserId: "dad",    fromUserEmoji: "👨‍🦳", timestamp: Date().addingTimeInterval(-1550)),
                        Reaction(emoji: "❤️", fromUserId: "hayden", fromUserEmoji: "👨‍💻", timestamp: Date().addingTimeInterval(-1400)),
                        Reaction(emoji: "❤️", fromUserId: "mengxi", fromUserEmoji: "🧑",   timestamp: Date().addingTimeInterval(-1200)),
                        Reaction(emoji: "🔥", fromUserId: "tommy",  fromUserEmoji: "👨‍🦱", timestamp: Date().addingTimeInterval(-1100)),
                        Reaction(emoji: "🔥", fromUserId: "eric",   fromUserEmoji: "👨",   timestamp: Date().addingTimeInterval(-1000)),
                        Reaction(emoji: "🤗", fromUserId: "songshu",fromUserEmoji: "🐿️",  timestamp: Date().addingTimeInterval(-900))
                    ],
                    notes: [
                        ContactNote(fromUserId: "dad",    fromUserName: "Dad",    fromUserEmoji: "👨‍🦳",
                                    text: "Take care of yourself, don't overwork 💪",
                                    timestamp: Date().addingTimeInterval(-850)),
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
