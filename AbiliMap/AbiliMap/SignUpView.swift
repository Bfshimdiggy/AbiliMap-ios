import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var fullName: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @State private var hasAgreedToPrivacyPolicy: Bool = false
    @State private var showPrivacyPolicy: Bool = false
    @State private var isVerificationSent: Bool = false
    @State private var navigateToSignIn: Bool = false

    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Spacer()

            TextField("Full Name", text: $fullName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 15)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.bottom, 15)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 15)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 15)

            HStack {
                Button(action: {
                    showPrivacyPolicy.toggle()
                }) {
                    Text("Privacy Policy")
                        .underline()
                }
                .sheet(isPresented: $showPrivacyPolicy) {
                    PrivacyPolicyView()
                }

                Toggle(isOn: $hasAgreedToPrivacyPolicy) {
                    Text("I agree to the Privacy Policy")
                }
            }
            .padding(.bottom, 15)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom, 10)
            }

            if isLoading {
                ProgressView("Creating Account...")
                    .padding()
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
                .disabled(!isFormValid())
                .padding(.bottom, 15)
            }

            if isVerificationSent {
                Text("A verification email has been sent to \(email). Please verify your email and proceed to sign in.")
                    .foregroundColor(.green)
                    .padding()

                Button(action: {
                    navigateToSignIn = true
                }) {
                    Text("Continue to Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                }
                .padding(.top, 10)
                .fullScreenCover(isPresented: $navigateToSignIn) {
                    SignInView() // Use your existing SignInView here
                }
            }

            Spacer()
        }
        .padding()
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

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            isLoading = false

            if let error = error {
                errorMessage = "Sign-Up failed: \(error.localizedDescription)"
                return
            }

            guard let user = authResult?.user else {
                errorMessage = "User creation failed."
                return
            }

            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            changeRequest.commitChanges { error in
                if let error = error {
                    errorMessage = "Failed to set user profile: \(error.localizedDescription)"
                }
            }

            user.sendEmailVerification { error in
                if let error = error {
                    errorMessage = "Failed to send verification email: \(error.localizedDescription)"
                } else {
                    isVerificationSent = true
                }
            }
        }
    }

    private func isFormValid() -> Bool {
        if email.isEmpty || password.isEmpty || confirmPassword.isEmpty || fullName.isEmpty {
            return false
        }
        if password.count < 6 {
            return false
        }
        if password != confirmPassword {
            return false
        }
        if !hasAgreedToPrivacyPolicy {
            return false
        }
        return true
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("""
                                Privacy Policy

                                Effective Date: January 5, 2025

                                Boonventures is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our [App Name] (the "App"). Please read this policy carefully to understand our views and practices regarding your personal data and how we will treat it.

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

                                To communicate with you about updates, promotions, and other information related to the App.

                                To ensure the security and integrity of the App.

                                3. How We Share Your Information

                                We do not sell your personal information. We may share your information in the following circumstances:

                                Service Providers: With third-party service providers who perform services on our behalf.

                                Legal Obligations: When required by law or to protect our legal rights.

                                Business Transfers: In connection with a merger, sale, or acquisition.

                                4. Your Choices and Rights

                                4.1 Access and Correction

                                You may access and update your personal information through your account settings.

                                4.2 Data Deletion

                                You can request the deletion of your personal data by contacting us at [Insert Contact Email].

                                4.3 Opt-Out

                                You may opt out of receiving promotional emails by following the unsubscribe link in those emails.

                                5. Security

                                We implement appropriate technical and organizational measures to protect your personal information from unauthorized access, use, or disclosure.

                                6. Data Retention

                                We retain your personal information only for as long as necessary to provide the App and fulfill the purposes outlined in this Privacy Policy.

                                7. Children's Privacy

                                The App is not intended for children under the age of 13, and we do not knowingly collect personal information from children.

                                8. International Data Transfers

                                If you are accessing the App from outside the country where we are located, please note that your information may be transferred to, stored, and processed in a country that may not have the same data protection laws as your jurisdiction.

                                9. Changes to This Privacy Policy

                                We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.



                                This Privacy Policy is effective as of the date stated above.
                """)
                .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}
