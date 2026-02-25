import SwiftUI

struct HeartWidget: View {
    let health: HealthSnapshot?
    let onSendHeartbeat: ([Double]) -> Void
    
    @State private var showSender = false
    @State private var tapTimestamps: [Date] = []
    @State private var isRecording = false
    @State private var heartScale: CGFloat = 1.0
    @State private var sentConfirmation = false
    @State private var waveformHeights: [CGFloat] = []
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Color.stHeartRed)
                            .font(.title2)
                            .scaleEffect(heartScale)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Heart")
                                .font(.caption)
                                .foregroundStyle(.stSecondaryText)
                            Text(health?.heartStatus.rawValue ?? "Unknown")
                                .font(.caption2)
                                .foregroundStyle(.stSecondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    GlassButton("Send Beat", icon: "waveform.path.ecg") {
                        withAnimation(.spring(response: 0.3)) {
                            showSender.toggle()
                            if showSender { resetRecording() }
                        }
                    }
                }
                
                if let health {
                    Text("\(health.heartRate.lowerBound)–\(health.heartRate.upperBound) BPM")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.stPrimaryText)
                }
                
                if showSender {
                    heartbeatSender
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .overlay {
            if sentConfirmation {
                SendConfirmationOverlay(
                    emoji: "💓",
                    message: "Heartbeat sent!",
                    isVisible: $sentConfirmation
                )
            }
        }
    }
    
    private var heartbeatSender: some View {
        VStack(spacing: 12) {
            Text("Tap your heartbeat rhythm")
                .font(.caption)
                .foregroundStyle(.stSecondaryText)
            
            // Waveform visualization
            HStack(spacing: 2) {
                ForEach(0..<20, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.stHeartRed.opacity(i < waveformHeights.count ? 0.8 : 0.15))
                        .frame(width: 4, height: i < waveformHeights.count ? waveformHeights[i] : 8)
                }
            }
            .frame(height: 40)
            .animation(.spring(response: 0.2), value: waveformHeights.count)
            
            // Tap area
            Button {
                recordTap()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.stHeartRed.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Circle()
                        .fill(Color.stHeartRed.opacity(0.3))
                        .frame(width: 60, height: 60)
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundStyle(Color.stHeartRed)
                        .scaleEffect(heartScale)
                }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: tapTimestamps.count)
            
            if tapTimestamps.count >= 3 {
                Button {
                    sendRecordedHeartbeat()
                } label: {
                    Text("Send (\(tapTimestamps.count) beats)")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(Color.stHeartRed)
                        )
                }
            }
        }
        .padding(.top, 4)
    }
    
    private func recordTap() {
        tapTimestamps.append(Date())
        
        let newHeight = CGFloat.random(in: 15...38)
        waveformHeights.append(newHeight)
        
        withAnimation(.easeOut(duration: 0.15)) { heartScale = 1.3 }
        withAnimation(.easeIn(duration: 0.15).delay(0.15)) { heartScale = 1.0 }
    }
    
    private func resetRecording() {
        tapTimestamps = []
        waveformHeights = []
        isRecording = false
    }
    
    private func sendRecordedHeartbeat() {
        var intervals: [Double] = []
        for i in 1..<tapTimestamps.count {
            intervals.append(tapTimestamps[i].timeIntervalSince(tapTimestamps[i - 1]))
        }
        onSendHeartbeat(intervals)
        sentConfirmation = true
        withAnimation(.spring(response: 0.3)) { showSender = false }
    }
}
