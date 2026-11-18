import SwiftUI

struct StartPage: View {

    var onContinue: () -> Void

    @State private var vm = StartViewModel()

    private let greenColor = Color(
        red: 38/255.0,
        green: 139/255.0,
        blue: 111/255.0
    )

    var body: some View {

        VStack(spacing: 0) {

            // MARK: Header

            HStack {
                Text("My Plants 🌱")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 73)

            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 1)

            // MARK: Mascot

            Image("PlantMascot")
                .resizable()
                .scaledToFit()
                .frame(width: 205, height: 212)
                .padding(.top, 58)

            // MARK: Title

            Text("Start your plant journey!")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 20)

            // MARK: Subtitle

            Text("Now all your plants will be in one place and\nwe will help you take care of them :)🪴")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.top, 23)

            // MARK: Button

            Button {
                vm.requestPermission {
                    onContinue()
                }
            } label: {

                HStack {
                    if vm.isSettingReminder {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Set Plant Reminder")
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
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
            .disabled(vm.isSettingReminder)
            .padding(.horizontal, 68)
            .padding(.top, 94)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    StartPage(onContinue: {})
}
