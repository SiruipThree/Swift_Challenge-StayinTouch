import SwiftUI

struct MoodWidget: View {
    let mood: MoodEntry?
    let contactName: String
    let myMood: MoodEntry
    let onSetMood: (MoodOption) -> Void
    
    @State private var showPicker = false
    @State private var sentConfirmation = false
    @State private var selectedMoodForAnimation: MoodOption?
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Text(mood?.emoji ?? "😶")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mood")
                                .font(.caption)
                                .foregroundStyle(.stSecondaryText)
                            Text(mood?.activity ?? "Unknown")
                                .font(.caption2)
                                .foregroundStyle(.stSecondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    // Tap to update your own mood
                    Button {
                        withAnimation(.spring(response: 0.3)) { showPicker.toggle() }
                    } label: {
                        HStack(spacing: 4) {
                            Text(myMood.emoji)
                                .font(.caption)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .rotationEffect(.degrees(showPicker ? 180 : 0))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.stMoodBlue.opacity(0.15))
                                .overlay(Capsule().stroke(Color.stMoodBlue.opacity(0.3), lineWidth: 0.5))
                        )
                    }
                }
                
                Text(mood?.label ?? "No mood set")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.stPrimaryText)
                
                if showPicker {
                    moodPickerGrid
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .overlay {
            if sentConfirmation, let selected = selectedMoodForAnimation {
                SendConfirmationOverlay(
                    emoji: selected.rawValue,
                    message: "Mood updated!",
                    isVisible: $sentConfirmation
                )
            }
        }
    }
    
    private var moodPickerGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How are you feeling?")
                .font(.caption)
                .foregroundStyle(.stSecondaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(MoodOption.allCases) { option in
                    Button {
                        selectedMoodForAnimation = option
                        onSetMood(option)
                        withAnimation(.spring(response: 0.3)) { showPicker = false }
                        sentConfirmation = true
                    } label: {
                        VStack(spacing: 4) {
                            Text(option.rawValue)
                                .font(.title2)
                            Text(option.label.replacingOccurrences(of: "Feeling ", with: ""))
                                .font(.system(size: 9))
                                .foregroundStyle(.stSecondaryText)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.05))
                        )
                    }
                }
            }
        }
        .padding(.top, 4)
    }
}
