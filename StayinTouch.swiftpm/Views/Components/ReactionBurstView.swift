import SwiftUI

/// Floating emoji burst animation — renders 8 emoji particles that fan upward
/// from `origin`, grow and then fade out over ~1.6 s.
struct ReactionBurstView: View {

    let emoji: String
    let origin: CGPoint
    var onFinished: () -> Void

    // Fixed launch vectors (dx, dy) — bias toward upward spread
    private static let vectors: [(CGFloat, CGFloat)] = [
        ( 0.00, -1.00),
        (-0.40, -0.92),
        ( 0.40, -0.92),
        (-0.75, -0.67),
        ( 0.75, -0.67),
        (-0.25, -1.00),
        ( 0.25, -1.00),
        ( 0.00, -0.80),
    ]

    @State private var offsets:   [CGSize]  = Array(repeating: .zero, count: 8)
    @State private var opacities: [Double]  = Array(repeating: 0,     count: 8)
    @State private var scales:    [CGFloat] = Array(repeating: 0.3,   count: 8)

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Text(emoji)
                    .font(.system(size: 26))
                    .scaleEffect(scales[i])
                    .offset(offsets[i])
                    .opacity(opacities[i])
            }
        }
        .position(origin)
        .allowsHitTesting(false)
        .onAppear { launch() }
    }

    private func launch() {
        let distances: [CGFloat] = [95, 80, 88, 105, 100, 85, 92, 115]
        for i in 0..<8 {
            let delay  = Double(i) * 0.055
            let dist   = distances[i]
            let vec    = Self.vectors[i]

            // Phase 1 — fly outward & appear
            withAnimation(.easeOut(duration: 0.85).delay(delay)) {
                offsets[i]   = CGSize(width: vec.0 * dist, height: vec.1 * dist)
                opacities[i] = 1.0
                scales[i]    = 1.1
            }
            // Phase 2 — fade out
            withAnimation(.easeIn(duration: 0.55).delay(delay + 0.75)) {
                opacities[i] = 0
                scales[i]    = 0.35
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { onFinished() }
    }
}
