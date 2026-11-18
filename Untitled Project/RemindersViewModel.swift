import Foundation
import Observation

@Observable
final class RemindersViewModel {

    private let store: ReminderStore

    private(set) var reminders: [PlantReminder] = []
    private(set) var checkedIDs: Set<String> = []

    init(store: ReminderStore = ReminderStore()) {
        self.store = store
        load()
    }

    // MARK: - Derived State (اللي تعرضه الـ Views)

    var checkedCount: Int {
        reminders.filter { checkedIDs.contains($0.id.uuidString) }.count
    }

    var progress: Double {
        guard !reminders.isEmpty else { return 0 }
        return Double(checkedCount) / Double(reminders.count)
    }

    var isAllDone: Bool {
        !reminders.isEmpty && checkedCount == reminders.count
    }

    var statusText: String {
        checkedCount == 0
        ? "Your plants are waiting for a sip 💦"
        : "\(checkedCount) of your plants feel loved today ✨"
    }

    func isChecked(_ reminder: PlantReminder) -> Bool {
        checkedIDs.contains(reminder.id.uuidString)
    }

    // MARK: - Load

    func load() {
        reminders = store.loadReminders()
        checkedIDs = store.loadCheckedIDs()
        migrateStartDates()
        resetIfNewDay()
    }

    // نبتات قديمة بدون startDate: نعطيها تاريخ مرة وحدة
    private func migrateStartDates() {

        var changed = false

        for i in reminders.indices where reminders[i].startDate == nil {
            reminders[i].startDate = Date()
            changed = true
        }

        if changed { store.saveReminders(reminders) }
    }

    // MARK: - Check / Uncheck

    func toggle(_ reminder: PlantReminder) {

        let key = reminder.id.uuidString

        if checkedIDs.contains(key) {
            checkedIDs.remove(key)
        } else {
            checkedIDs.insert(key)
        }

        store.saveCheckedIDs(checkedIDs)
    }

    func resetIfNewDay() {

        let today = Date().formatted(.iso8601.year().month().day())

        if store.loadCheckedDate() != today {
            store.saveCheckedDate(today)
            checkedIDs = []
            store.saveCheckedIDs([])
        }
    }

    // MARK: - Add / Update / Delete

    func add(_ reminder: PlantReminder) {
        reminders.append(reminder)
        store.saveReminders(reminders)
        NotificationManager.shared.schedule(reminder)
    }

    func update(_ reminder: PlantReminder) {

        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else {
            return
        }

        reminders[index] = reminder
        store.saveReminders(reminders)
        NotificationManager.shared.schedule(reminder)
    }

    func delete(_ reminder: PlantReminder) {

        reminders.removeAll { $0.id == reminder.id }
        store.saveReminders(reminders)

        checkedIDs.remove(reminder.id.uuidString)
        store.saveCheckedIDs(checkedIDs)

        NotificationManager.shared.cancel(reminder)
    }

    // MARK: - Notifications

    func rescheduleNotifications() {
        NotificationManager.shared.rescheduleAll(reminders)
    }
}
