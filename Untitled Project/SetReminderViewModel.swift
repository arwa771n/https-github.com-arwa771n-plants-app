import Foundation
import Observation

@Observable
final class SetReminderViewModel {

    // MARK: - Form State

    var plantName = ""
    var wateringDays = "Every day"
    var room = "Bedroom"
    var light = "Full sun"
    var water = "20-50 ml"

    var showNameAlert = false

    // MARK: - Options

    let wateringOptions = [
        "Every day",
        "Every 2 days",
        "Every 3 days",
        "Once a week",
        "Every 10 days",
        "Every 2 weeks"
    ]

    let roomOptions = [
        "Bedroom",
        "Living Room",
        "Kitchen",
        "Balcony",
        "Bathroom"
    ]

    let lightOptions = [
        "Full sun",
        "Partial sun",
        "Low light"
    ]

    let waterOptions = [
        "20-50 ml",
        "50-100 ml",
        "100-200 ml",
        "200-300 ml"
    ]

    // MARK: - Editing

    // لو فيه نبتة معناه وضع التعديل
    let editingReminder: PlantReminder?

    var isEditing: Bool { editingReminder != nil }

    init(editing reminder: PlantReminder? = nil) {

        editingReminder = reminder

        if let r = reminder {
            plantName = r.plantName
            wateringDays = r.wateringDays
            room = r.room
            light = r.light
            water = r.water
        }
    }

    // MARK: - Actions

    /// يرجع true إذا انحفظ (عشان الـ View تسكّر الشاشة)
    func save(to list: RemindersViewModel) -> Bool {

        let trimmedName = plantName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            showNameAlert = true
            return false
        }

        if var editing = editingReminder {

            // إذا تغير التكرار نبدأ العد من اليوم
            if editing.wateringDays != wateringDays {
                editing.startDate = Date()
            }

            editing.plantName = trimmedName
            editing.wateringDays = wateringDays
            editing.room = room
            editing.light = light
            editing.water = water

            list.update(editing)

        } else {

            list.add(
                PlantReminder(
                    plantName: trimmedName,
                    wateringDays: wateringDays,
                    room: room,
                    light: light,
                    water: water,
                    startDate: Date()
                )
            )
        }

        return true
    }

    func delete(from list: RemindersViewModel) {
        guard let editing = editingReminder else { return }
        list.delete(editing)
    }
}
