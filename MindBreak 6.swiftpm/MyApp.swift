import SwiftUI
import TipKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    try? await Tips.configure()
                }
        }
    }
}
