import SwiftUI

@Observable
class AppViewModel {
    
    // MARK: - State
    
    var currentUser: User = MockDataProvider.me
    var contacts: [User] = MockDataProvider.allContacts
    var selectedContact: User
    var hasCompletedOnboarding = false
    
    // Per-contact data (keyed by user id)
    var moods: [String: MoodEntry] = [:]
    var health: [String: HealthSnapshot] = [:]
    var activity: [String: ActivitySnapshot] = [:]
    var todayPosts: [String: [TodayPost]] = [:]
    
    // My own mood (editable by user)
    var myMood: MoodEntry
    
    // Interaction state
    var sentHeartbeats: [HeartbeatMessage] = []
    var sentEncouragements: [Encouragement] = []
    var sentNudges: [NudgeMessage] = []
    
    // UI state
    var showMoodPicker = false
    var showHeartbeatSender = false
    var showEncouragementPicker = false
    var showTodayDetail = false
    var showNudgeConfirmation = false
    var activeNudgeAnimation = false
    
    // MARK: - Init
    
    init() {
        selectedContact = MockDataProvider.allContacts[0]
        myMood = MockDataProvider.moodFor("me")
        loadAllData()
    }
    
    // MARK: - Data Loading
    
    private func loadAllData() {
        let allIds = ["me"] + contacts.map(\.id)
        for userId in allIds {
            moods[userId] = MockDataProvider.moodFor(userId)
            health[userId] = MockDataProvider.healthFor(userId)
            activity[userId] = MockDataProvider.activityFor(userId)
            todayPosts[userId] = MockDataProvider.todayPostsFor(userId)
        }
    }
    
    // MARK: - Contact Selection
    
    func selectContact(_ user: User) {
        withAnimation(.easeInOut(duration: 0.4)) {
            selectedContact = user
        }
    }
    
    // MARK: - Mood
    
    func setMyMood(_ option: MoodOption) {
        let entry = MoodEntry(
            emoji: option.rawValue,
            label: option.label,
            activity: option.activity,
            timestamp: Date()
        )
        myMood = entry
        moods["me"] = entry
        showMoodPicker = false
    }
    
    // MARK: - Heartbeat
    
    func sendHeartbeat(pattern: [Double]) {
        let message = HeartbeatMessage(
            fromUserId: currentUser.id,
            pattern: pattern,
            timestamp: Date()
        )
        sentHeartbeats.append(message)
        showHeartbeatSender = false
    }
    
    // MARK: - Encouragement
    
    func sendEncouragement(_ option: EncouragementOption) {
        let encouragement = Encouragement(
            message: option.message,
            emoji: option.emoji,
            fromUserId: currentUser.id,
            timestamp: Date()
        )
        sentEncouragements.append(encouragement)
        showEncouragementPicker = false
    }
    
    // MARK: - Today Reactions
    
    func addReaction(_ reaction: ReactionOption, to post: TodayPost) {
        guard let userId = todayPosts.first(where: { $0.value.contains(where: { $0.id == post.id }) })?.key,
              let index = todayPosts[userId]?.firstIndex(where: { $0.id == post.id }) else { return }
        
        let newReaction = Reaction(
            emoji: reaction.rawValue,
            fromUserId: currentUser.id,
            timestamp: Date()
        )
        todayPosts[userId]?[index].reactions.append(newReaction)
    }
    
    // MARK: - Nudge
    
    func sendNudge() {
        let nudge = NudgeMessage(
            fromUserId: currentUser.id,
            toUserId: selectedContact.id,
            timestamp: Date()
        )
        sentNudges.append(nudge)
        
        withAnimation(.easeOut(duration: 1.5)) {
            activeNudgeAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            withAnimation { self?.activeNudgeAnimation = false }
        }
    }
    
    // MARK: - Computed
    
    var distanceMiles: Int {
        currentUser.location.distanceInMiles(to: selectedContact.location)
    }
    
    var selectedMood: MoodEntry? { moods[selectedContact.id] }
    var selectedHealth: HealthSnapshot? { health[selectedContact.id] }
    var selectedActivity: ActivitySnapshot? { activity[selectedContact.id] }
    var selectedTodayPosts: [TodayPost] { todayPosts[selectedContact.id] ?? [] }
    var myTodayPosts: [TodayPost] { todayPosts["me"] ?? [] }
}
