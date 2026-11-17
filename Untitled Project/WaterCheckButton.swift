import SwiftUI

struct WaterCheckButton: View {
    @Binding var isOn: Bool
    private let green = Color(red: 38/255, green: 139/255, blue: 111/255)

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.25)) { isOn.toggle() }
        } label: {
            Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 28))
                .foregroundStyle(isOn ? green : Color.gray)
        }
        .buttonStyle(.plain)
    }
}
