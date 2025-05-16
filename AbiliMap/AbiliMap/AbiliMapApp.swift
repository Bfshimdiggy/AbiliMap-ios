import SwiftUI
import Firebase

@main
struct AbiliMapApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var firebaseService = FirebaseService.shared // Use shared instance of FirebaseService
    @StateObject private var userSession = UserSession.shared // Use shared instance of UserSession
    @StateObject private var firebaseAuthListener = FirebaseAuthListener() // Listen to Firebase Auth state changes

    init() {
        // Ensure Firebase is configured before the app starts
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(firebaseService) // Provide FirebaseService to the view hierarchy
                    .environmentObject(userSession) // Provide UserSession to the view hierarchy
                    .environmentObject(firebaseAuthListener) // Provide FirebaseAuthListener to observe auth state changes
            }
        }
    }
}

// AppDelegate to conform to UIApplicationDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    // You can add additional app delegate methods if needed.
}
