import SwiftUI

@main
struct MyApp: App {

    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("hasSeenStartPage")
    private var hasSeenStartPage = false

    // ViewModel واحد مشترك بين كل الشاشات
    @State private var remindersVM = RemindersViewModel()

    init() {
        NotificationManager.shared.configure()
    }

    var body: some Scene {

        WindowGroup {

            Group {
                if hasSeenStartPage {

                    NoReminders()

                } else {

                    StartPage {
                        hasSeenStartPage = true
                    }
                }
            }
            .environment(remindersVM)
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    remindersVM.load()
                    remindersVM.rescheduleNotifications()
                }
            }
        }
    }
}
