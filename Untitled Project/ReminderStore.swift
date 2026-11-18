import Foundation

/// الطبقة الوحيدة اللي تتعامل مع UserDefaults (نفس المفاتيح القديمة، فبياناتك ما تضيع)
struct ReminderStore {

    private let defaults = UserDefaults.standard

    private let remindersKey = "savedPlantReminders"
    private let checkedKey = "checkedPlantIDs"
    private let checkedDateKey = "checkedDate"

    // MARK: - Reminders

    func loadReminders() -> [PlantReminder] {
        guard
            let json = defaults.string(forKey: remindersKey),
            let data = json.data(using: .utf8),
            let decoded = try? JSONDecoder().decode([PlantReminder].self, from: data)
        else { return [] }

        return decoded
    }

    func saveReminders(_ reminders: [PlantReminder]) {
        guard
            let data = try? JSONEncoder().encode(reminders),
            let json = String(data: data, encoding: .utf8)
        else { return }

        defaults.set(json, forKey: remindersKey)
    }

    // MARK: - Checked Plants

    func loadCheckedIDs() -> Set<String> {
        guard
            let json = defaults.string(forKey: checkedKey),
            let data = json.data(using: .utf8),
            let decoded = try? JSONDecoder().decode(Set<String>.self, from: data)
        else { return [] }

        return decoded
    }

    func saveCheckedIDs(_ ids: Set<String>) {
        guard
            let data = try? JSONEncoder().encode(ids),
            let json = String(data: data, encoding: .utf8)
        else { return }

        defaults.set(json, forKey: checkedKey)
    }

    // MARK: - Checked Date

    func loadCheckedDate() -> String {
        defaults.string(forKey: checkedDateKey) ?? ""
    }

    func saveCheckedDate(_ date: String) {
        defaults.set(date, forKey: checkedDateKey)
    }
}
