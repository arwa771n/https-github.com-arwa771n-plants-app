import SwiftUI

@main
struct MyApp: App {

    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("hasSeenStartPage")
    private var hasSeenStartPage = false

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
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    NotificationManager.shared.rescheduleAll()
                }
            }
        }
    }
}
