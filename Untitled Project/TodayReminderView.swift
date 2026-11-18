import SwiftUI

struct TodayReminderView: View {

    @Environment(RemindersViewModel.self) private var vm

    private let backgroundColor = Color.black
    private let greenColor = Color(red: 38/255.0, green: 139/255.0, blue: 111/255.0)

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
                    Text(vm.statusText)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.gray.opacity(0.3))
                            Capsule()
                                .fill(greenColor)
                                .frame(width: geo.size.width * vm.progress)
                        }
                    }
                    .frame(height: 5)
                }
                .padding(.horizontal)
                .animation(.easeInOut, value: vm.checkedIDs)

                // القايمة
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(vm.reminders) { plant in
                            plantRow(plant)
                            Divider().background(Color.gray.opacity(0.3))
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.top)
        }
        .onAppear { vm.resetIfNewDay() }
    }

    // MARK: - Row

    private func plantRow(_ plant: PlantReminder) -> some View {
        let isChecked = vm.isChecked(plant)

        return Button {
            vm.toggle(plant)
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

#Preview {
    TodayReminderView()
        .environment(RemindersViewModel())
}
