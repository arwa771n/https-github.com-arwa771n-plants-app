import SwiftUI

struct PlantReminder: Identifiable, Codable {
    var id = UUID()
    var plantName: String
    var wateringDays: String
    var room: String
    var light: String
    var water: String
    var startDate: Date? = nil   // ✅ جديد
}

struct SetReminder: View {

    @Environment(\.dismiss) private var dismiss

    @AppStorage("savedPlantReminders")
    private var savedPlantReminders = ""

    // لو فيه نبتة معناه وضع التعديل
    var editingReminder: PlantReminder? = nil

    @State private var plantName = ""
    @State private var wateringDays = "Every day"
    @State private var room = "Bedroom"
    @State private var light = "Full sun"
    @State private var water = "20-50 ml"

    @State private var showNameAlert = false

    private var isEditing: Bool { editingReminder != nil }

    // MARK: - Colors

    private let backgroundColor = Color(
        red: 28/255.0,
        green: 28/255.0,
        blue: 30/255.0
    )

    private let cardColor = Color(
        red: 44/255.0,
        green: 44/255.0,
        blue: 46/255.0
    )

    private let greenColor = Color(
        red: 38/255.0,
        green: 139/255.0,
        blue: 111/255.0
    )

    // MARK: - Options

    private let wateringOptions = [
        "Every day",
        "Every 2 days",
        "Every 3 days",
        "Once a week",
        "Every 10 days",
        "Every 2 weeks"
    ]

    private let roomOptions = [
        "Bedroom",
        "Living Room",
        "Kitchen",
        "Balcony",
        "Bathroom"
    ]

    private let lightOptions = [
        "Full sun",
        "Partial sun",
        "Low light"
    ]

    private let waterOptions = [
        "20-50 ml",
        "50-100 ml",
        "100-200 ml",
        "200-300 ml"
    ]

    // MARK: - Body

    var body: some View {

        GeometryReader { geometry in

            VStack(spacing: 0) {

                // MARK: Header

                HStack {

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(cardColor)
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text(isEditing ? "Edit Reminder" : "Set Reminder")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        saveReminder()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(greenColor)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 18)
                .frame(height: 65)

                // MARK: Form

                VStack(spacing: 0) {

                    // Plant Name

                    HStack(spacing: 5) {

                        TextField(
                            "",
                            text: $plantName,
                            prompt: Text("Plant Name")
                                .foregroundColor(.white.opacity(0.85))
                        )
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .tint(greenColor)

                        Text("|")
                            .foregroundColor(greenColor)

                        Text("Pothos")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.35))
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 42)
                    .background(cardColor)
                    .clipShape(Capsule())
                    .padding(.horizontal, 12)
                    .padding(.top, 20)

                    // Room and Light

                    VStack(spacing: 0) {

                        SelectionRow(
                            icon: "paperplane",
                            title: "Room",
                            selection: $room,
                            options: roomOptions
                        )

                        Divider()
                            .overlay(Color.white.opacity(0.04))
                            .padding(.horizontal, 12)

                        SelectionRow(
                            icon: "sun.max",
                            title: "Light",
                            selection: $light,
                            options: lightOptions
                        )
                    }
                    .background(cardColor)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .padding(.horizontal, 12)
                    .padding(.top, 35)

                    // Watering Days and Water

                    VStack(spacing: 0) {

                        SelectionRow(
                            icon: "drop",
                            title: "Watering Days",
                            selection: $wateringDays,
                            options: wateringOptions
                        )

                        Divider()
                            .overlay(Color.white.opacity(0.04))
                            .padding(.horizontal, 12)

                        SelectionRow(
                            icon: "drop",
                            title: "Water",
                            selection: $water,
                            options: waterOptions
                        )
                    }
                    .background(cardColor)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .padding(.horizontal, 12)
                    .padding(.top, 35)

                    // Delete Reminder (وضع التعديل فقط)

                    if isEditing {
                        Button {
                            deleteReminder()
                        } label: {
                            Text("Delete Reminder")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 49)
                                .background(cardColor)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 35)
                    }

                    Spacer(minLength: 20)
                }

                Spacer(minLength: 0)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .background(backgroundColor)
        }
        .background(backgroundColor.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if let r = editingReminder {
                plantName = r.plantName
                wateringDays = r.wateringDays
                room = r.room
                light = r.light
                water = r.water
            }
        }
        .alert("Plant Name Required", isPresented: $showNameAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter your plant name before saving.")
        }
    }

    // MARK: - Save Reminder

    private func saveReminder() {

        let trimmedName = plantName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            showNameAlert = true
            return
        }

        var reminders = loadReminders()
        var saved: PlantReminder   // ✅ جديد

        if let editing = editingReminder,
           let index = reminders.firstIndex(where: { $0.id == editing.id }) {

            // ✅ جديد: إذا تغير التكرار نبدأ العد من اليوم
            if reminders[index].wateringDays != wateringDays {
                reminders[index].startDate = Date()
            }

            // تعديل النبتة الموجودة بنفس الـ id
            reminders[index].plantName = trimmedName
            reminders[index].wateringDays = wateringDays
            reminders[index].room = room
            reminders[index].light = light
            reminders[index].water = water
            saved = reminders[index]

        } else {

            let newReminder = PlantReminder(
                plantName: trimmedName,
                wateringDays: wateringDays,
                room: room,
                light: light,
                water: water,
                startDate: Date()
            )

            reminders.append(newReminder)
            saved = newReminder
        }

        if persist(reminders) {
            NotificationManager.shared.schedule(saved)   // ✅ جديد
            dismiss()
        }
    }

    // MARK: - Delete Reminder

    private func deleteReminder() {

        guard let editing = editingReminder else { return }

        var reminders = loadReminders()
        reminders.removeAll { $0.id == editing.id }

        if persist(reminders) {
            NotificationManager.shared.cancel(editing)   // ✅ جديد
            dismiss()
        }
    }

    // MARK: - Storage Helpers

    private func loadReminders() -> [PlantReminder] {

        guard let data = savedPlantReminders.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(
                [PlantReminder].self,
                from: data
              ) else {
            return []
        }

        return decoded
    }

    private func persist(_ reminders: [PlantReminder]) -> Bool {

        guard let encoded = try? JSONEncoder().encode(reminders),
              let json = String(data: encoded, encoding: .utf8) else {
            return false
        }

        savedPlantReminders = json
        return true
    }
}

// MARK: - Selection Row

struct SelectionRow: View {

    let icon: String
    let title: String
    @Binding var selection: String
    let options: [String]

    @State private var showOptions = false

    var body: some View {

        HStack(spacing: 8) {

            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 17)

            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.85))

            Spacer()

            Button {
                showOptions = true
            } label: {
                HStack(spacing: 4) {

                    Text(selection)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.55))

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .popover(isPresented: $showOptions) {
                optionsList
                    .presentationCompactAdaptation(.popover)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 49)
        .contentShape(Rectangle())
    }

    // قائمة الخيارات: النص ثابت على اليسار والعلامة على اليمين

    private var optionsList: some View {

        VStack(spacing: 0) {

            ForEach(options, id: \.self) { option in

                Button {
                    selection = option
                    showOptions = false
                } label: {
                    HStack {

                        Text(option)
                            .font(.system(size: 15))
                            .foregroundColor(.white)

                        Spacer(minLength: 28)

                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .opacity(option == selection ? 1 : 0) // يحجز المكان
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
        .frame(minWidth: 190)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SetReminder()
    }
}
