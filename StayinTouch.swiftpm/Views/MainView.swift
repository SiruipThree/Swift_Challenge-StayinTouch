import SwiftUI

struct MainView: View {
    @Bindable var viewModel: AppViewModel
    
    @State private var showNudgeConfirm = false
    
    var body: some View {
        ZStack {
            Color.stBackground.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // User Selector
                    UserSelectorBar(
                        currentUser: viewModel.currentUser,
                        contacts: viewModel.contacts,
                        selectedContact: viewModel.selectedContact,
                        onSelect: { viewModel.selectContact($0) }
                    )
                    
                    // Mood & Heart row
                    HStack(spacing: 12) {
                        MoodWidget(
                            mood: viewModel.selectedMood,
                            contactName: viewModel.selectedContact.name,
                            myMood: viewModel.myMood,
                            onSetMood: { viewModel.setMyMood($0) }
                        )
                        
                        HeartWidget(
                            health: viewModel.selectedHealth,
                            onSendHeartbeat: { viewModel.sendHeartbeat(pattern: $0) }
                        )
                    }
                    
                    // Globe
                    GlobeContainerView(
                        from: viewModel.currentUser.location,
                        to: viewModel.selectedContact.location,
                        distanceMiles: viewModel.distanceMiles,
                        daysApart: viewModel.selectedContact.daysApart,
                        contactName: viewModel.selectedContact.name,
                        showNudgeRipple: viewModel.activeNudgeAnimation,
                        onNudge: {
                            viewModel.sendNudge()
                            showNudgeConfirm = true
                        }
                    )
                    
                    // Rings & Today row
                    HStack(alignment: .top, spacing: 12) {
                        RingsWidget(
                            activity: viewModel.selectedActivity,
                            onSendEncouragement: { viewModel.sendEncouragement($0) }
                        )
                        
                        TodayWidget(
                            posts: viewModel.selectedTodayPosts,
                            myPosts: viewModel.myTodayPosts,
                            contactName: viewModel.selectedContact.name,
                            onReaction: { option, post in viewModel.addReaction(option, to: post) }
                        )
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            
            // Nudge confirmation overlay
            if showNudgeConfirm {
                SendConfirmationOverlay(
                    emoji: "👋",
                    message: "Nudge sent to \(viewModel.selectedContact.name)!",
                    isVisible: $showNudgeConfirm
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}
