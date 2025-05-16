import SwiftUI
import FirebaseAuth
import Combine

class UserSession: ObservableObject {
    // The shared instance for UserSession
    static let shared = UserSession(firebaseService: FirebaseService.shared)

    @Published var userId: String?
    @Published var userName: String?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let firebaseService: FirebaseService
    
    init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            if let user = user {
                self.userId = user.uid
                self.userName = user.displayName
                self.isLoggedIn = user.isEmailVerified
                self.error = nil
            } else {
                self.userId = nil
                self.userName = nil
                self.isLoggedIn = false
            }
        }
    }
    
    func updateUserInfo(completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, "No user is currently signed in")
            return
        }
        
        isLoading = true
        error = nil
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = userName
        
        changeRequest.commitChanges { [weak self] error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.error = error.localizedDescription
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func logout() {
        isLoading = true
        error = nil
        
        do {
            try Auth.auth().signOut()
            userId = nil
            userName = nil
            isLoggedIn = false
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
    
    func checkLoginStatus() {
        guard let user = Auth.auth().currentUser else {
            isLoggedIn = false
            return
        }
        
        isLoggedIn = user.isEmailVerified
    }
    
    func deleteAccount(completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, "No user is currently signed in")
            return
        }
        
        isLoading = true
        error = nil
        
        firebaseService.deleteUserAccount { [weak self] success, error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if success {
                self.userId = nil
                self.userName = nil
                self.isLoggedIn = false
                completion(true, nil)
            } else {
                self.error = error
                completion(false, error)
            }
        }
    }
    
    func resendVerificationEmail(completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, "No user is currently signed in")
            return
        }
        
        isLoading = true
        error = nil
        
        user.sendEmailVerification { [weak self] error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.error = error.localizedDescription
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
}
