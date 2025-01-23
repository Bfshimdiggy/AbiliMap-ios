import Firebase
import Combine

class FirebaseAuthListener: ObservableObject {
    @Published var user: User?

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            if let user = user {
                // Update the session when the user logs in
                UserSession.shared.updateUserId(user.uid)
            } else {
                // Log out the session if the user logs out
                UserSession.shared.logOut()
            }
        }
    }
}
