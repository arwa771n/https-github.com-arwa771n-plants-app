import SwiftUI

struct TodayReminderView: View {

    // نفس المفتاح المستخدم في NoReminders
    @AppStorage("savedPlantReminders") private var savedPlantReminders: String = ""

    // النبتات اللي انسقت اليوم (تتخزن وتتصفر كل يوم)
    @AppStorage("checkedPlantIDs") private var checkedPlantIDs: String = ""
    @AppStorage("checkedDate") private var checkedDate: String = ""

    private let backgroundColor = Color.black
    private let greenColor = Color(red: 38/255.0, green: 139/255.0, blue: 111/255.0)

    // MARK: - Data

    private var reminders: [PlantReminder] {
        guard let data = savedPlantReminders.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([PlantReminder].self, from: data)
        else { return [] }
        return decoded
    }

    private var checkedIDs: Set<String> {
        guard let data = checkedPlantIDs.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(Set<String>.self, from: data)
        else { return [] }
        return decoded
    }

    private func saveChecked(_ ids: Set<String>) {
        if let data = try? JSONEncoder().encode(ids),
           let string = String(data: data, encoding: .utf8) {
            checkedPlantIDs = string
        }
    }

    private func toggle(_ plant: PlantReminder) {
        var ids = checkedIDs
        let key = plant.id.uuidString
        if ids.contains(key) { ids.remove(key) } else { ids.insert(key) }
        saveChecked(ids)
    }

    // يصفّر الاختيار إذا تغير اليوم
    private func resetIfNewDay() {
        let today = Date().formatted(.iso8601.year().month().day())
        if checkedDate != today {
            checkedDate = today
            checkedPlantIDs = ""
        }
    }

    // MARK: - Progress

    private var checkedCount: Int {
        reminders.filter { checkedIDs.contains($0.id.uuidString) }.count
    }

    private var progress: Double {
        guard !reminders.isEmpty else { return 0 }
        return Double(checkedCount) / Double(reminders.count)
    }

    private var statusText: String {
        checkedCount == 0
        ? "Your plants are waiting for a sip 💦"
        : "\(checkedCount) of your plants feel loved today ✨"
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {

                Text("My Plants 🌱")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal)

                Divider().background(Color.gray.opacity(0.3))

                // البار
                VStack(spacing: 10) {
                    Text(statusText)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.gray.opacity(0.3))
                            Capsule()
                                .fill(greenColor)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 5)
                }
                .padding(.horizontal)
                .animation(.easeInOut, value: checkedPlantIDs)

                // القايمة
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(reminders) { plant in
                            plantRow(plant)
                            Divider().background(Color.gray.opacity(0.3))
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.top)
        }
        .onAppear(perform: resetIfNewDay)
    }

    // MARK: - Row

    private func plantRow(_ plant: PlantReminder) -> some View {
        let isChecked = checkedIDs.contains(plant.id.uuidString)

        return Button {
            toggle(plant)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isChecked ? greenColor : .gray)

                VStack(alignment: .leading, spacing: 6) {
                    Text("in \(plant.room)")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(plant.plantName)
                        .font(.title2)
                        .foregroundColor(isChecked ? .white : .gray)

                    HStack(spacing: 8) {
                        tag(icon: "sun.max", text: plant.light, active: isChecked)
                        tag(icon: "drop", text: plant.water, active: isChecked)
                    }
                }
                Spacer()
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func tag(icon: String, text: String, active: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .foregroundColor(active ? .white : .gray)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.25))
        .clipShape(Capsule())
    }
}
