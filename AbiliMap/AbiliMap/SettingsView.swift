import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSession: UserSession
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    @State private var showPrivacyPolicy: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var isDeleting: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Spacer()

            // Privacy Policy Button
            Button(action: {
                showPrivacyPolicy.toggle()
            }) {
                Text("Privacy Policy")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyContentView()
            }

            // Log Out Button
            Button(action: {
                userSession.logOut()  // Log out functionality
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Log Out")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding()
            
            // Delete Account Button
            Button(action: {
                showDeleteConfirmation = true
            }) {
                Text("Delete Account")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(8)
            }
            .padding()
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Account"),
                    message: Text("Are you sure you want to permanently delete your account? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteAccount()
                    },
                    secondaryButton: .cancel()
                )
            }
            
            if isDeleting {
                ProgressView("Deleting account...")
                    .padding()
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deleteAccount() {
        isDeleting = true
        errorMessage = nil
        
        userSession.deleteAccount { success, error in
            isDeleting = false
            
            if success {
                // Account deleted successfully, dismiss the settings view
                presentationMode.wrappedValue.dismiss()
            } else {
                // Show error message
                errorMessage = error ?? "Failed to delete account. Please try again."
            }
        }
    }
}

struct PrivacyPolicyContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("""
                Privacy Policy

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
                    .font(.body)
                    .padding()

                // Add more sections as needed
            }
            .padding()
        }
    }
}
