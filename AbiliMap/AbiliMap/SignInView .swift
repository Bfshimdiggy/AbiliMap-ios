import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showForgotPassword = false
    @State private var resetEmail = ""
    @State private var resetMessage = ""

    var body: some View {
        VStack {
            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: signIn) {
                if isLoading {
                    ProgressView()
                        .padding()
                } else {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()

            Button(action: { showForgotPassword.toggle() }) {
                Text("Forgot Password?")
                    .underline()
                    .foregroundColor(.blue)
            }
            .padding()

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(resetEmail: $resetEmail, resetMessage: $resetMessage)
        }
    }

    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }

        isLoading = true
        errorMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoading = false

            if let error = error {
                errorMessage = "Error signing in: \(error.localizedDescription)"
                return
            }

            guard let user = authResult?.user else {
                errorMessage = "Unable to sign in. Please try again."
                return
            }

            // Update the user session
            userSession.updateUserId(user.uid)
            userSession.updateUserName(user.displayName ?? user.email ?? "User")
            userSession.isLoggedIn = true
        }
    }
}

struct ForgotPasswordView: View {
    @Binding var resetEmail: String
    @Binding var resetMessage: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Forgot Password")
                .font(.title)
                .padding()

            TextField("Email Address", text: $resetEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()

            if !resetMessage.isEmpty {
                Text(resetMessage)
                    .foregroundColor(resetMessage.contains("sent") ? .green : .red)
                    .padding()
            }

            Button(action: sendResetEmail) {
                Text("Send Reset Email")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()

            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Text("Cancel")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .padding()
    }

    private func sendResetEmail() {
        guard !resetEmail.isEmpty else {
            resetMessage = "Please enter a valid email address."
            return
        }

        Auth.auth().sendPasswordReset(withEmail: resetEmail) { error in
            if let error = error {
                resetMessage = "Error: \(error.localizedDescription)"
            } else {
                resetMessage = "Password reset email sent to \(resetEmail)."
            }
        }
    }
}
