import SwiftUI

struct IssuePopupView: View {
    @Binding var showPopup: Bool
    @State private var category: String = "Select type of site"
    @State private var fullName: String = ""
    @State private var issueDescription: String = ""
    @State private var businessName: String = ""
    @State private var address: String = ""
    @State private var county: String = ""
    @State private var email: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var userSession: UserSession
    @Environment(\.presentationMode) var presentationMode

    var categories = ["Private Business", "City Property"]

    var body: some View {
        NavigationView {
            VStack {
                Text("Submit an Issue")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top)

                // Category Picker with adaptive gradient
                Menu {
                    ForEach(categories, id: \.self) { categoryOption in
                        Button(action: {
                            self.category = categoryOption
                        }) {
                            Text(categoryOption)
                        }
                    }
                } label: {
                    Text(category)
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            category == "Select type of site"
                                ? LinearGradient(gradient: Gradient(colors: [.gray, .gray]), startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.bottom, 15)

                // Form fields
                if category == "Private Business" {
                    TextField("Business Name", text: $businessName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 5)
                    TextField("Address", text: $address)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 5)
                } else if category == "City Property" {
                    TextField("Address", text: $address)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 5)
                    TextField("County", text: $county)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 5)
                }

                TextField("Your Name", text: $fullName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 5)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.bottom, 5)

                TextField("Description of Issue", text: $issueDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 80)
                    .padding(.bottom, 10)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                }

                // Submit Button
                if isSubmitting {
                    ProgressView("Submitting...")
                        .padding()
                } else {
                    Button(action: submitIssue) {
                        Text("Submit Issue")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                isFormValid()
                                    ? LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(gradient: Gradient(colors: [.gray, .gray]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }
                    .disabled(!isFormValid())
                    .padding(.bottom, 10)
                }

                // Close Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
    }

    private func submitIssue() {
        guard isFormValid() else {
            errorMessage = "Please fill in all required fields."
            return
        }

        isSubmitting = true
        errorMessage = nil

        guard let userId = userSession.userId, !userId.isEmpty else {
            errorMessage = "User is not logged in."
            isSubmitting = false
            return
        }

        let newIssue = Issue(
            fullName: fullName,
            issueDescription: issueDescription,
            category: category,
            businessName: businessName.isEmpty ? nil : businessName,
            address: address,
            county: county.isEmpty ? nil : county,
            email: email
        )

        firebaseService.addIssue(newIssue) { success in
            isSubmitting = false
            if success {
                presentationMode.wrappedValue.dismiss()
            } else {
                errorMessage = "Failed to submit issue. Please try again."
            }
        }
    }

    private func isFormValid() -> Bool {
        if fullName.isEmpty || email.isEmpty || issueDescription.isEmpty || address.isEmpty {
            return false
        }

        if category == "Private Business" && businessName.isEmpty {
            return false
        }

        if category == "City Property" && county.isEmpty {
            return false
        }

        return true
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
