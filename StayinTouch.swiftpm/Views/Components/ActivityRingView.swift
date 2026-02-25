import SwiftUI

struct ActivityRingView: View {
    let move: Double
    let exercise: Double
    let stand: Double
    var size: CGFloat = 60
    
    var body: some View {
        ZStack {
            ringLayer(progress: stand, color: .stStandRing, width: size * 0.13, radius: size * 0.25)
            ringLayer(progress: exercise, color: .stExerciseRing, width: size * 0.13, radius: size * 0.35)
            ringLayer(progress: move, color: .stMoveRing, width: size * 0.13, radius: size * 0.45)
        }
        .frame(width: size, height: size)
    }
    
    private func ringLayer(progress: Double, color: Color, width: CGFloat, radius: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: width)
                .frame(width: radius * 2, height: radius * 2)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
                .frame(width: radius * 2, height: radius * 2)
                .rotationEffect(.degrees(-90))
        }
    }
}
