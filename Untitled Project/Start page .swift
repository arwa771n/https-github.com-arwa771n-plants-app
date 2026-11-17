import SwiftUI

struct StartPage: View {

    var onContinue: () -> Void

    @State private var isSettingReminder = false

    private let greenColor = Color(
        red: 38/255.0,
        green: 139/255.0,
        blue: 111/255.0
    )

    var body: some View {

        GeometryReader { geometry in

            VStack(spacing: 0) {

                HStack {
                    Text("My Plants 🌱")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 60)

                Rectangle()
                    .fill(Color.white.opacity(0.10))
                    .frame(height: 1)

                VStack(spacing: 0) {

                    Spacer()
                        .frame(height: geometry.size.height * 0.055)

                    Image("PlantMascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 155)

                    Text("Start your plant journey!")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 22)

                    Text("""
                    Now all your plants will be in one place and
                    we will help you take care of them! 🌱🪴
                    """)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.top, 17)

                    Button {
                        activateReminder()
                    } label: {

                        HStack {
                            if isSettingReminder {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Set Plant Reminder")
                                    .font(.system(
                                        size: 13,
                                        weight: .semibold
                                    ))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            LinearGradient(
                                colors: [
                                    greenColor,
                                    Color(
                                        red: 27/255.0,
                                        green: 112/255.0,
                                        blue: 91/255.0
                                    )
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(isSettingReminder)
                    .padding(.horizontal, 52)
                    .padding(.top, 72)

                    Spacer()
                }

                Spacer(minLength: 0)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .background(Color.black)
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    // MARK: - Reminder Permission

    private func activateReminder() {

        isSettingReminder = true

        // ✅ جديد: نطلب الصلاحية فقط، والجدولة تصير من SetReminder
        NotificationManager.shared.requestPermission { _ in
            onContinue()
        }
    }
}

#Preview {
    StartPage(onContinue: {})
}
