import SwiftUI

struct RingsWidget: View {
    let activity: ActivitySnapshot?
    let onSendEncouragement: (EncouragementOption) -> Void
    
    @State private var showOptions = false
    @State private var sentConfirmation = false
    @State private var selectedEncouragement: EncouragementOption?
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Rings")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.stPrimaryText)
                    
                    Spacer()
                    
                    GlassButton("Cheer", icon: "megaphone.fill") {
                        withAnimation(.spring(response: 0.3)) { showOptions.toggle() }
                    }
                }
                
                if let activity {
                    HStack(spacing: 16) {
                        ActivityRingView(
                            move: activity.moveProgress,
                            exercise: activity.exerciseProgress,
                            stand: activity.standProgress,
                            size: 70
                        )
                        
                        VStack(alignment: .leading, spacing: 6) {
                            ringRow(
                                value: activity.moveCalories,
                                goal: activity.moveGoal,
                                unit: "cal",
                                color: .stMoveRing
                            )
                            ringRow(
                                value: activity.exerciseMinutes,
                                goal: activity.exerciseGoal,
                                unit: "min",
                                color: .stExerciseRing
                            )
                            ringRow(
                                value: activity.standHours,
                                goal: activity.standGoal,
                                unit: "hrs",
                                color: .stStandRing
                            )
                        }
                    }
                }
                
                if showOptions {
                    encouragementOptions
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .overlay {
            if sentConfirmation, let sel = selectedEncouragement {
                SendConfirmationOverlay(
                    emoji: sel.emoji,
                    message: sel.message,
                    isVisible: $sentConfirmation
                )
            }
        }
    }
    
    private func ringRow(value: Int, goal: Int, unit: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.stPrimaryText)
            Text("/ \(goal) \(unit)")
                .font(.caption)
                .foregroundStyle(.stSecondaryText)
        }
    }
    
    private var encouragementOptions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Send encouragement")
                .font(.caption)
                .foregroundStyle(.stSecondaryText)
            
            ForEach(EncouragementOption.allCases) { option in
                Button {
                    selectedEncouragement = option
                    onSendEncouragement(option)
                    sentConfirmation = true
                    withAnimation(.spring(response: 0.3)) { showOptions = false }
                } label: {
                    HStack(spacing: 8) {
                        Text(option.emoji)
                        Text(option.message)
                            .font(.callout)
                            .foregroundStyle(.stPrimaryText)
                        Spacer()
                        Image(systemName: "paperplane.fill")
                            .font(.caption)
                            .foregroundStyle(Color.stAccent)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.05))
                    )
                }
            }
        }
        .padding(.top, 4)
    }
}
