import SwiftUI

struct NoReminders: View {

    @AppStorage("savedPlantReminders")
    private var savedPlantReminders = ""

    // النبتات اللي انسقت اليوم (تتصفر كل يوم)
    @AppStorage("checkedPlantIDs")
    private var checkedPlantIDs = ""

    @AppStorage("checkedDate")
    private var checkedDate = ""

    // النبتة اللي تنعدل (تفتح sheet)
    @State private var editingReminder: PlantReminder? = nil

    // إضافة ريمايندر جديد (تفتح sheet من تحت)
    @State private var showAddReminder = false

    private let backgroundColor = Color.black

    private let greenColor = Color(
        red: 38/255.0,
        green: 139/255.0,
        blue: 111/255.0
    )

    // MARK: - Saved Reminders

    private var reminders: [PlantReminder] {

        guard let data = savedPlantReminders.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(
                [PlantReminder].self,
                from: data
              ) else {
            return []
        }

        return decoded
    }

    // MARK: - Checked Plants

    private var checkedIDs: Set<String> {

        guard let data = checkedPlantIDs.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(
                Set<String>.self,
                from: data
              ) else {
            return []
        }

        return decoded
    }

    private func saveChecked(_ ids: Set<String>) {

        if let data = try? JSONEncoder().encode(ids),
           let string = String(data: data, encoding: .utf8) {
            checkedPlantIDs = string
        }
    }

    private func toggle(_ reminder: PlantReminder) {

        var ids = checkedIDs
        let key = reminder.id.uuidString

        if ids.contains(key) {
            ids.remove(key)
        } else {
            ids.insert(key)
        }

        saveChecked(ids)
    }

    private func resetIfNewDay() {

        let today = Date().formatted(
            .iso8601.year().month().day()
        )

        if checkedDate != today {
            checkedDate = today
            checkedPlantIDs = ""
        }
    }

    private func deleteReminder(_ reminder: PlantReminder) {

        // ✅ جديد: نلغي إشعارات النبتة المحذوفة
        NotificationManager.shared.cancel(reminder)

        var all = reminders
        all.removeAll { $0.id == reminder.id }

        if let data = try? JSONEncoder().encode(all),
           let json = String(data: data, encoding: .utf8) {
            savedPlantReminders = json
        }

        // نشيل التشيك حق النبتة المحذوفة
        var ids = checkedIDs
        ids.remove(reminder.id.uuidString)
        saveChecked(ids)
    }

    // MARK: - Progress

    private var checkedCount: Int {
        reminders.filter {
            checkedIDs.contains($0.id.uuidString)
        }.count
    }

    private var progress: Double {
        guard !reminders.isEmpty else { return 0 }
        return Double(checkedCount) / Double(reminders.count)
    }

    // true لما كل النباتات تنسقت
    private var isAllDone: Bool {
        !reminders.isEmpty && checkedCount == reminders.count
    }

    private var statusText: String {
        checkedCount == 0
        ? "Your plants are waiting for a sip 💦"
        : "\(checkedCount) of your plants feel loved today ✨"
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            GeometryReader { geometry in

                VStack(spacing: 0) {

                    // MARK: Header

                    HStack {

                        Text("My Plants 🌱")
                            .font(.system(size: 27, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 76)

                    Rectangle()
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 1)

                    // MARK: Content

                    if reminders.isEmpty {

                        Spacer()

                        Text("No reminders set yet..")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.40))

                        Spacer()

                    } else if isAllDone {

                        allDoneView

                    } else {

                        // MARK: Progress Bar

                        VStack(spacing: 10) {

                            Text(statusText)
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)

                            GeometryReader { barGeo in

                                ZStack(alignment: .leading) {

                                    Capsule()
                                        .fill(Color.white.opacity(0.15))

                                    Capsule()
                                        .fill(greenColor)
                                        .frame(
                                            width: barGeo.size.width * progress
                                        )
                                }
                            }
                            .frame(height: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .animation(.easeInOut, value: checkedPlantIDs)

                        // MARK: List (سحب لليسار للحذف)

                        List {
                            ForEach(reminders) { reminder in

                                reminderRow(reminder)
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.black)
                                    .swipeActions(
                                        edge: .trailing,
                                        allowsFullSwipe: true
                                    ) {
                                        Button(role: .destructive) {
                                            deleteReminder(reminder)
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                        .tint(.red)
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }

                    // MARK: Add Button

                    HStack {

                        Spacer()

                        Button {
                            showAddReminder = true
                        } label: {

                            Image(systemName: "plus")
                                .font(
                                    .system(
                                        size: 27,
                                        weight: .semibold
                                    )
                                )
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(greenColor)
                                .clipShape(Circle())
                                .shadow(
                                    color: greenColor.opacity(0.25),
                                    radius: 5
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 25)
                        .padding(.bottom, 18)
                    }
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .background(backgroundColor)
            }
            .background(Color.black.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: resetIfNewDay)
        .sheet(item: $editingReminder) { reminder in
            SetReminder(editingReminder: reminder)
        }
        .sheet(isPresented: $showAddReminder) {
            SetReminder()
        }
    }

    // MARK: - All Done View

    private var allDoneView: some View {

        VStack(spacing: 0) {

            Spacer()

            Image("PlantMascot")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Text("All Done! 🎉")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 24)

            Text("All Reminders Completed")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.55))
                .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Reminder Row

    private func reminderRow(
        _ reminder: PlantReminder
    ) -> some View {

        let isChecked = checkedIDs.contains(reminder.id.uuidString)

        return HStack(spacing: 14) {

            // الدايرة: للتشيك (رمادية، وإذا انختارت تصير خضراء)
            Button {
                toggle(reminder)
            } label: {
                Image(
                    systemName: isChecked
                    ? "checkmark.circle.fill"
                    : "circle"
                )
                .font(.system(size: 24))
                .foregroundColor(isChecked ? greenColor : .gray)
                .frame(width: 36, height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // باقي الصف: يفتح شاشة التعديل
            Button {
                editingReminder = reminder
            } label: {

                HStack {

                    VStack(alignment: .leading, spacing: 7) {

                        HStack(spacing: 5) {

                            Image(systemName: "paperplane")
                                .font(.system(size: 10))

                            Text("in \(reminder.room)")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(
                            .white.opacity(isChecked ? 0.45 : 0.25)
                        )

                        Text(reminder.plantName)
                            .font(.system(size: 19, weight: .medium))
                            .foregroundColor(
                                isChecked ? .white : .white.opacity(0.4)
                            )

                        HStack(spacing: 6) {

                            detailTag(
                                icon: "sun.max",
                                text: reminder.light,
                                active: isChecked
                            )

                            detailTag(
                                icon: "drop",
                                text: reminder.water,
                                active: isChecked
                            )

                            detailTag(
                                icon: "calendar",
                                text: reminder.wateringDays,
                                active: isChecked
                            )
                        }
                    }

                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 1)
        }
    }

    // MARK: - Detail Tag

    private func detailTag(
        icon: String,
        text: String,
        active: Bool
    ) -> some View {

        HStack(spacing: 4) {

            Image(systemName: icon)
                .font(.system(size: 9))

            Text(text)
                .font(.system(size: 9))
                .lineLimit(1)
        }
        .foregroundColor(.white.opacity(active ? 0.65 : 0.3))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Color(
                red: 35/255.0,
                green: 35/255.0,
                blue: 38/255.0
            )
        )
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    NoReminders()
}
