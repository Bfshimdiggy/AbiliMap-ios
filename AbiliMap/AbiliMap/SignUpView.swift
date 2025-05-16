import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var userSession: UserSession
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var fullName: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @State private var hasAgreedToPrivacyPolicy: Bool = false
    @State private var showPrivacyPolicy: Bool = false
    @State private var isVerificationSent: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                VStack(spacing: 15) {
                    TextField("Full Name", text: $fullName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)

                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disabled(isLoading)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)
                }
                .padding(.horizontal)

                VStack(spacing: 10) {
                    HStack {
                        Button(action: {
                            showPrivacyPolicy.toggle()
                        }) {
                            Text("Privacy Policy")
                                .underline()
                                .foregroundColor(.blue)
                        }
                        .disabled(isLoading)
                        .sheet(isPresented: $showPrivacyPolicy) {
                            PrivacyPolicyView()
                        }

                        Spacer()

                        Toggle(isOn: $hasAgreedToPrivacyPolicy) {
                            Text("I agree")
                        }
                        .disabled(isLoading)
                    }
                }
                .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                if isLoading {
                    ProgressView("Creating Account...")
                        .padding()
                } else if isVerificationSent {
                    VStack(spacing: 15) {
                        Text("A verification email has been sent to \(email).")
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Text("Please verify your email and proceed to sign in.")
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Continue to Sign In")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Button(action: signUp) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isFormValid() ? Color.blue : Color.gray)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }
                    .disabled(!isFormValid() || isLoading)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .foregroundColor(colorScheme == .dark ? .white : .black)
    }

    private func signUp() {
        guard isFormValid() else {
            errorMessage = "Please ensure all fields are filled correctly."
            return
        }

        isLoading = true
        errorMessage = nil

        firebaseService.signUp(email: email, password: password, fullName: fullName) { success, error in
            isLoading = false

            if success {
                isVerificationSent = true
            } else {
                errorMessage = error ?? "Failed to create account. Please try again."
            }
        }
    }

    private func isFormValid() -> Bool {
        guard !email.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty,
              !fullName.isEmpty,
              password.count >= 6,
              password == confirmPassword,
              hasAgreedToPrivacyPolicy else {
            return false
        }
        return true
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("""
                Effective Date: January 5, 2025

                Boon Ventures is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our AbiliMap (the "App"). Please read this policy carefully to understand our views and practices regarding your personal data and how we will treat it.

                1. Information We Collect

                1.1 Information You Provide to Us

                Account Information: When you create an account, we collect personal information such as your name, email address, and password.

                Issue Submissions: Information you submit when reporting issues, including descriptions, photos, and location data.

                1.2 Information We Collect Automatically

                Usage Data: We may collect information about your interactions with the App, such as your IP address, device information, and app usage patterns.

                Cookies and Tracking Technologies: We use cookies and similar tracking technologies to monitor user activity and improve our services.

                1.3 Information from Third Parties

                We may receive information about you from third-party services if you choose to link your account or use third-party features.

                2. How We Use Your Information

                We use the information we collect for various purposes, including:

                To provide, maintain, and improve the App.
                To manage your account and provide customer support.
                """)
                .padding(.horizontal)
            }
        }
    }
}
