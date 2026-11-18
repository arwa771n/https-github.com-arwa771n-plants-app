import Foundation
import Observation

@Observable
final class StartViewModel {

    var isSettingReminder = false

    func requestPermission(completion: @escaping () -> Void) {

        isSettingReminder = true

        NotificationManager.shared.requestPermission { _ in
            completion()
        }
    }
}
