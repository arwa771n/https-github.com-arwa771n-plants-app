import Foundation

struct PlantReminder: Identifiable, Codable {
    var id = UUID()
    var plantName: String
    var wateringDays: String
    var room: String
    var light: String
    var water: String
    var startDate: Date? = nil
}
