import Foundation

struct Coordinate: Equatable {
    let latitude: Double
    let longitude: Double
    
    func distanceInMiles(to other: Coordinate) -> Int {
        let R = 3958.8 // Earth radius in miles
        let dLat = (other.latitude - latitude) * .pi / 180
        let dLon = (other.longitude - longitude) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(latitude * .pi / 180) * cos(other.latitude * .pi / 180) *
                sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return Int(R * c)
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
