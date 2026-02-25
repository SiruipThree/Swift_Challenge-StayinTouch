import SwiftUI

struct SendConfirmationOverlay: View {
    let emoji: String
    let message: String
    @Binding var isVisible: Bool
    
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    
    var body: some View {
        if isVisible {
            VStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 48))
                Text(message)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 0
                        scale = 0.8
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isVisible = false
                    }
                }
            }
        }
    }
}

struct PulseRippleView: View {
    @Binding var isAnimating: Bool
    
    @State private var ripple1: CGFloat = 0
    @State private var ripple2: CGFloat = 0
    @State private var ripple3: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.stAccent.opacity(0.6 - Double(ripple1) * 0.6), lineWidth: 2)
                .frame(width: 20 + ripple1 * 200, height: 20 + ripple1 * 200)
            Circle()
                .stroke(Color.stAccent.opacity(0.5 - Double(ripple2) * 0.5), lineWidth: 1.5)
                .frame(width: 20 + ripple2 * 200, height: 20 + ripple2 * 200)
            Circle()
                .stroke(Color.stAccent.opacity(0.4 - Double(ripple3) * 0.4), lineWidth: 1)
                .frame(width: 20 + ripple3 * 200, height: 20 + ripple3 * 200)
        }
        .opacity(isAnimating ? 1 : 0)
        .onChange(of: isAnimating) { _, newValue in
            if newValue { startRipple() }
        }
    }
    
    private func startRipple() {
        ripple1 = 0; ripple2 = 0; ripple3 = 0
        withAnimation(.easeOut(duration: 1.5)) { ripple1 = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 1.5)) { ripple2 = 1 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 1.5)) { ripple3 = 1 }
        }
    }
}
