import SwiftUI
import FirebaseAuth

class FirebaseAuthListener: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private var handle: AuthStateDidChangeListenerHandle?
    private let userSession: UserSession
    
    init(userSession: UserSession = .shared) {
        self.userSession = userSession
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            if let user = user {
                self.currentUser = user
                self.isAuthenticated = user.isEmailVerified
                self.userSession.userId = user.uid
                self.userSession.userName = user.displayName
                self.userSession.isLoggedIn = user.isEmailVerified
            } else {
                self.currentUser = nil
                self.isAuthenticated = false
                self.userSession.userId = nil
                self.userSession.userName = nil
                self.userSession.isLoggedIn = false
            }
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
} 