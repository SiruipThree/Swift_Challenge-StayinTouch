import SwiftUI

struct GlobeContainerView: View {
    let from: Coordinate
    let to: Coordinate
    let distanceMiles: Int
    let daysApart: Int
    let contactName: String
    var showNudgeRipple: Bool = false
    let onNudge: () -> Void
    
    var body: some View {
        ZStack {
            GlobeView(
                fromCoordinate: from,
                toCoordinate: to,
                distanceMiles: distanceMiles,
                daysApart: daysApart,
                showNudgeRipple: showNudgeRipple
            )
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            if showNudgeRipple {
                PulseRippleView(isAnimating: .constant(true))
                    .allowsHitTesting(false)
            }
            
            VStack {
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.stAccent)
                    Text("\(formattedDistance) • \(daysApart) days apart")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: Capsule())
                .padding(.bottom, 12)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: onNudge) {
                VStack(spacing: 4) {
                    Image(systemName: "hand.wave.fill")
                        .font(.title3)
                    Text("Nudge")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundStyle(Color.stAccent)
                .padding(10)
                .glassEffect(.regular.tint(Color.stAccent.opacity(0.3)), in: Circle())
            }
            .padding(12)
        }
    }
    
    private var formattedDistance: String {
        "\(distanceMiles.formatted(.number.grouping(.automatic))) miles"
    }
}
