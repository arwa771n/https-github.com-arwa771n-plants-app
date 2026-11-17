import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let prefix = "plant-"

    // وقت الإشعار كل يوم (غيّره زي ما تبغى)
    private let notifyHour = 9
    private let notifyMinute = 0

    // عدد المواعيد القادمة اللي تتجدول للنبتة (iOS يسمح بـ 64 إشعار كحد أقصى)
    private let upcomingCount = 8

    // MARK: - Setup (استدعها من MyApp.init)

    func configure() {
        center.delegate = self

        // نشيل الإشعارات القديمة العامة (اليومي + التجريبي)
        center.removePendingNotificationRequests(
            withIdentifiers: ["PlantDailyReminder", "PlantTestReminder"]
        )
    }

    // يخلي الإشعار يظهر والتطبيق مفتوح
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // MARK: - Permission

    func requestPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    // MARK: - Schedule / Cancel (نبتة وحدة)

    func schedule(_ reminder: PlantReminder) {
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestPermission { granted in
                    if granted { self.replace(reminder) }
                }
            case .authorized, .provisional, .ephemeral:
                self.replace(reminder)
            default:
                break // المستخدم رافض الصلاحية
            }
        }
    }

    func cancel(_ reminder: PlantReminder) {
        let key = prefix + reminder.id.uuidString
        center.getPendingNotificationRequests { pending in
            let ids = pending.map(\.identifier).filter { $0.hasPrefix(key) }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    private func replace(_ reminder: PlantReminder) {
        let key = prefix + reminder.id.uuidString
        center.getPendingNotificationRequests { pending in
            let ids = pending.map(\.identifier).filter { $0.hasPrefix(key) }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)

            for request in self.makeRequests(for: reminder) {
                self.center.add(request)
            }
        }
    }

    // MARK: - Reschedule All (يتنفذ كل ما يفتح التطبيق)

    func rescheduleAll() {

        var reminders = loadReminders()

        // نبتات قديمة بدون startDate: نعطيها تاريخ مرة وحدة ونحفظه
        var changed = false
        for i in reminders.indices where reminders[i].startDate == nil {
            reminders[i].startDate = Date()
            changed = true
        }
        if changed { saveReminders(reminders) }

        center.getPendingNotificationRequests { pending in

            // نشيل كل إشعارات النباتات (تشمل المحذوفة)
            let ids = pending.map(\.identifier).filter { $0.hasPrefix(self.prefix) }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)

            for reminder in reminders {
                for request in self.makeRequests(for: reminder) {
                    self.center.add(request)
                }
            }
        }
    }

    // MARK: - Build Requests

    private func makeRequests(
        for reminder: PlantReminder
    ) -> [UNNotificationRequest] {

        let key = prefix + reminder.id.uuidString
        let days = Self.intervalDays(from: reminder.wateringDays)

        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body = "Time to water \(reminder.plantName) in the \(reminder.room) 💦 (\(reminder.water))"
        content.sound = .default

        // كل يوم: إشعار واحد متكرر
        if days == 1 {

            var comps = DateComponents()
            comps.hour = notifyHour
            comps.minute = notifyMinute

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: comps,
                repeats: true
            )

            return [UNNotificationRequest(
                identifier: key,
                content: content,
                trigger: trigger
            )]
        }

        // كل N يوم: نجدول المواعيد القادمة من تاريخ البداية
        let cal = Calendar.current
        let anchor = cal.startOfDay(for: reminder.startDate ?? Date())

        var requests: [UNNotificationRequest] = []
        var step = 0

        while requests.count < upcomingCount && step < 1000 {

            let offset = step * days
            step += 1

            guard
                let day = cal.date(byAdding: .day, value: offset, to: anchor),
                let fire = cal.date(
                    bySettingHour: notifyHour,
                    minute: notifyMinute,
                    second: 0,
                    of: day
                )
            else { break }

            if fire <= Date() { continue }

            let comps = cal.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: fire
            )

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: comps,
                repeats: false
            )

            requests.append(
                UNNotificationRequest(
                    identifier: "\(key)-\(requests.count)",
                    content: content,
                    trigger: trigger
                )
            )
        }

        return requests
    }

    static func intervalDays(from text: String) -> Int {
        switch text {
        case "Every day":      return 1
        case "Every 2 days":   return 2
        case "Every 3 days":   return 3
        case "Once a week":    return 7
        case "Every 10 days":  return 10
        case "Every 2 weeks":  return 14
        default:               return 1
        }
    }

    // MARK: - Storage (نفس مفتاح @AppStorage)

    private let storageKey = "savedPlantReminders"

    private func loadReminders() -> [PlantReminder] {
        guard
            let json = UserDefaults.standard.string(forKey: storageKey),
            let data = json.data(using: .utf8),
            let decoded = try? JSONDecoder().decode([PlantReminder].self, from: data)
        else { return [] }

        return decoded
    }

    private func saveReminders(_ reminders: [PlantReminder]) {
        guard
            let data = try? JSONEncoder().encode(reminders),
            let json = String(data: data, encoding: .utf8)
        else { return }

        UserDefaults.standard.set(json, forKey: storageKey)
    }
}
