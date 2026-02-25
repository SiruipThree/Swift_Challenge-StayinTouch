import SwiftUI

extension Color {
    static let stBackground = Color(red: 0.05, green: 0.05, blue: 0.12)
    static let stCardBackground = Color.white.opacity(0.08)
    static let stCardBorder = Color.white.opacity(0.15)
    static let stAccent = Color(red: 0.35, green: 0.78, blue: 0.98) // Soft cyan
    static let stAccentGlow = Color(red: 0.35, green: 0.78, blue: 0.98).opacity(0.4)
    
    static let stMoveRing = Color(red: 0.98, green: 0.24, blue: 0.30)
    static let stExerciseRing = Color(red: 0.55, green: 0.95, blue: 0.15)
    static let stStandRing = Color(red: 0.10, green: 0.88, blue: 0.88)
    
    static let stHeartRed = Color(red: 0.95, green: 0.25, blue: 0.35)
    static let stMoodBlue = Color(red: 0.40, green: 0.70, blue: 0.95)
}

extension ShapeStyle where Self == Color {
    static var stPrimaryText: Color { .white }
    static var stSecondaryText: Color { .white.opacity(0.6) }
}
