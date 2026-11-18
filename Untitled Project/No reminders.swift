import SwiftUI

struct NoReminders: View {

    @Environment(RemindersViewModel.self) private var vm

    // حالة الواجهة فقط (أي sheet مفتوح)
    @State private var editingReminder: PlantReminder? = nil
    @State private var showAddReminder = false

    private let backgroundColor = Color.black

    private let greenColor = Color(
        red: 38/255.0,
        green: 139/255.0,
        blue: 111/255.0
    )

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

                    if vm.reminders.isEmpty {

                        Spacer()

                        Text("No reminders set yet..")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.40))

                        Spacer()

                    } else if vm.isAllDone {

                        allDoneView

                    } else {

                        // MARK: Progress Bar

                        VStack(spacing: 10) {

                            Text(vm.statusText)
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
                                            width: barGeo.size.width * vm.progress
                                        )
                                }
                            }
                            .frame(height: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .animation(.easeInOut, value: vm.checkedIDs)

                        // MARK: List (سحب لليسار للحذف)

                        List {
                            ForEach(vm.reminders) { reminder in

                                reminderRow(reminder)
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.black)
                                    .swipeActions(
                                        edge: .trailing,
                                        allowsFullSwipe: true
                                    ) {
                                        Button(role: .destructive) {
                                            vm.delete(reminder)
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
        .onAppear { vm.resetIfNewDay() }
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

        let isChecked = vm.isChecked(reminder)

        return HStack(spacing: 14) {

            // الدايرة: للتشيك
            Button {
                vm.toggle(reminder)
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
        .environment(RemindersViewModel())
}
