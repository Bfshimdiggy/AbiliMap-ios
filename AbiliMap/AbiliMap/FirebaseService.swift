import Firebase
import FirebaseFirestore

class FirebaseService: ObservableObject {
    private var db = Firestore.firestore()

    // Getter method to expose the Firestore database instance
    func getFirestoreDB() -> Firestore {
        return db
    }

    // Add a new issue to Firestore
    func addIssue(_ issue: Issue, completion: @escaping (Bool) -> Void) {
        guard let userId = UserSession.shared.userId else {
            completion(false)
            return
        }

        let currentUser = Auth.auth().currentUser
        guard let email = currentUser?.email, let fullName = currentUser?.displayName else {
            completion(false)
            return
        }

        var newIssue = issue
        newIssue.email = email
        newIssue.id = UUID().uuidString
        newIssue.fullName = fullName

        db.collection("issues").document(newIssue.id).setData(newIssue.dictionary) { error in
            if let error = error {
                print("Error adding issue: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    // Retrieve issues for the current user
    func getUserIssues(completion: @escaping ([Issue]) -> Void) {
        guard let userId = UserSession.shared.userId else {
            completion([])
            return
        }

        let currentUser = Auth.auth().currentUser
        guard let email = currentUser?.email else {
            completion([])
            return
        }

        db.collection("issues")
            .whereField("email", isEqualTo: email)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching issues: \(error)")
                    completion([])
                } else {
                    var issues: [Issue] = []
                    for document in querySnapshot!.documents {
                        if let issue = Issue(from: document.data()) {
                            issues.append(issue)
                        }
                    }
                    completion(issues)
                }
            }
    }

    // Sign in function for Firebase Authentication
    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            // On successful sign-in, update session
            UserSession.shared.userId = result?.user.uid
            UserSession.shared.userName = result?.user.displayName
            completion(true, nil)
        }
    }

    // Sign out function for Firebase Authentication
    func signOut() {
        do {
            try Auth.auth().signOut()
            UserSession.shared.logOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    // Sign up function for Firebase Authentication
    func signUp(email: String, password: String, fullName: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            // Successfully signed up, update the user's profile
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = fullName
            changeRequest?.commitChanges { error in
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    // On successful profile update, store session data
                    UserSession.shared.userId = result?.user.uid
                    UserSession.shared.userName = fullName
                    completion(true, nil)
                }
            }
        }
    }

    // Delete user account function
    func deleteUserAccount(completion: @escaping (Bool, String?) -> Void) {
        let user = Auth.auth().currentUser
        
        guard let user = user else {
            completion(false, "No user is signed in")
            return
        }
        
        // Delete user from Firebase Authentication
        user.delete { error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            // Successfully deleted user account
            completion(true, nil)
        }
    }
}
