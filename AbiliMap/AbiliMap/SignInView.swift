import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var firebaseService: FirebaseService
    @Environment(\.presentationMode) var presentationMode
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
                .disabled(isLoading)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disabled(isLoading)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: signIn) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                } else {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isFormValid() ? Color.blue : Color.gray)
                        .cornerRadius(8)
                }
            }
            .disabled(!isFormValid() || isLoading)
            .padding()

            Button(action: { showForgotPassword.toggle() }) {
                Text("Forgot Password?")
                    .underline()
                    .foregroundColor(.blue)
            }
            .disabled(isLoading)
            .padding()

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(resetEmail: $resetEmail, resetMessage: $resetMessage)
        }
    }

    private func signIn() {
        guard isFormValid() else {
            errorMessage = "Please enter both email and password."
            return
        }

        isLoading = true
        errorMessage = ""

        firebaseService.signIn(email: email, password: password) { success, error in
            isLoading = false
            
            if success {
                userSession.checkLoginStatus()
                presentationMode.wrappedValue.dismiss()
            } else {
                errorMessage = error ?? "Failed to sign in. Please try again."
            }
        }
    }

    private func isFormValid() -> Bool {
        !email.isEmpty && !password.isEmpty
    }
}

struct ForgotPasswordView: View {
    @Binding var resetEmail: String
    @Binding var resetMessage: String
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false

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
                .disabled(isLoading)

            if !resetMessage.isEmpty {
                Text(resetMessage)
                    .foregroundColor(resetMessage.contains("sent") ? .green : .red)
                    .padding()
            }

            Button(action: sendResetEmail) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                } else {
                    Text("Send Reset Email")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isFormValid() ? Color.blue : Color.gray)
                        .cornerRadius(8)
                }
            }
            .disabled(!isFormValid() || isLoading)
            .padding()

            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Text("Cancel")
                    .foregroundColor(.red)
            }
            .disabled(isLoading)
            .padding()
        }
        .padding()
    }

    private func sendResetEmail() {
        guard isFormValid() else {
            resetMessage = "Please enter a valid email address."
            return
        }

        isLoading = true
        resetMessage = ""

        Auth.auth().sendPasswordReset(withEmail: resetEmail) { error in
            isLoading = false
            if let error = error {
                resetMessage = "Error: \(error.localizedDescription)"
            } else {
                resetMessage = "Password reset email sent to \(resetEmail)."
                // Clear the email field after successful send
                resetEmail = ""
            }
        }
    }

    private func isFormValid() -> Bool {
        !resetEmail.isEmpty
    }
}
