import Foundation
import FirebaseAuth

class UserSession: ObservableObject {
    // The shared instance for UserSession
    static let shared = UserSession()

    @Published var userId: String?
    @Published var userName: String?
    @Published var isLoggedIn: Bool = false

    private init() {
        // Initialize with saved data if available
        if let savedUserId = UserDefaults.standard.string(forKey: "userId") {
            self.userId = savedUserId
        }
        if let savedUserName = UserDefaults.standard.string(forKey: "userName") {
            self.userName = savedUserName
        }
        checkLoginStatus() // Ensure the login status is checked on initialization
    }

    func updateUserName(_ name: String) {
        self.userName = name
        UserDefaults.standard.set(name, forKey: "userName")
    }

    func logOut() {
        // Remove user data from UserDefaults
        self.userId = nil
        self.userName = nil
        self.isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userName")

        // Log out from Firebase
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out from Firebase: \(error.localizedDescription)")
        }
    }

    func updateUserId(_ id: String) {
        self.userId = id
        UserDefaults.standard.set(id, forKey: "userId")
    }

    func checkLoginStatus() {
        if let user = Auth.auth().currentUser {
            self.userId = user.uid
            self.userName = user.displayName ?? user.email
            self.isLoggedIn = true
            // Save user info to UserDefaults
            UserDefaults.standard.set(user.uid, forKey: "userId")
            UserDefaults.standard.set(user.displayName ?? user.email, forKey: "userName")
        } else {
            self.isLoggedIn = false
        }
    }
}
