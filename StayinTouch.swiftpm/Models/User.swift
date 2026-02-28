import Foundation
import CoreLocation

struct Coordinate: Equatable {
    let latitude: Double
    let longitude: Double
    
    func distanceInMiles(to other: Coordinate) -> Int {
        let from = CLLocation(latitude: latitude, longitude: longitude)
        let to = CLLocation(latitude: other.latitude, longitude: other.longitude)
        let miles = from.distance(from: to) / 1609.344
        return Int(miles.rounded())
    }
}

struct User: Identifiable, Equatable {
    let id: String
    let name: String
    let avatarEmoji: String
    let location: Coordinate
    let locationName: String
    let lastSeenDate: Date
    let isOnline: Bool
    
    var daysApart: Int {
        Calendar.current.dateComponents([.day], from: lastSeenDate, to: .now).day ?? 0
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
