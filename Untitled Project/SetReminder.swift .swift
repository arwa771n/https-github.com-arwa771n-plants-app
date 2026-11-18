import SwiftUI

struct SetReminder: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(RemindersViewModel.self) private var list

    @State private var vm: SetReminderViewModel

    // نفس الاستدعاء القديم: SetReminder() أو SetReminder(editingReminder: x)
    init(editingReminder: PlantReminder? = nil) {
        _vm = State(initialValue: SetReminderViewModel(editing: editingReminder))
    }

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

                    Text(vm.isEditing ? "Edit Reminder" : "Set Reminder")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        if vm.save(to: list) {
                            dismiss()
                        }
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
                            text: $vm.plantName,
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
                            selection: $vm.room,
                            options: vm.roomOptions
                        )

                        Divider()
                            .overlay(Color.white.opacity(0.04))
                            .padding(.horizontal, 12)

                        SelectionRow(
                            icon: "sun.max",
                            title: "Light",
                            selection: $vm.light,
                            options: vm.lightOptions
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
                            selection: $vm.wateringDays,
                            options: vm.wateringOptions
                        )

                        Divider()
                            .overlay(Color.white.opacity(0.04))
                            .padding(.horizontal, 12)

                        SelectionRow(
                            icon: "drop",
                            title: "Water",
                            selection: $vm.water,
                            options: vm.waterOptions
                        )
                    }
                    .background(cardColor)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .padding(.horizontal, 12)
                    .padding(.top, 35)

                    // Delete Reminder (وضع التعديل فقط)

                    if vm.isEditing {
                        Button {
                            vm.delete(from: list)
                            dismiss()
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
        .alert("Plant Name Required", isPresented: $vm.showNameAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter your plant name before saving.")
        }
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
                            .opacity(option == selection ? 1 : 0)
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
            .environment(RemindersViewModel())
    }
}
