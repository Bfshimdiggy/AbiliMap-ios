import SwiftUI
import PhotosUI

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
    @State private var showSuccessAlert: Bool = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedPhotoData: [Data] = []
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var userSession: UserSession
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    var categories = ["Private Business", "City Property"]

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
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
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    category == "Select type of site"
                                        ? LinearGradient(gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 15)

                        // Form fields
                        Group {
                            if category == "Private Business" {
                                TextField("Business Name", text: $businessName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.bottom, 10)
                                TextField("Address", text: $address)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.bottom, 10)
                            } else if category == "City Property" {
                                TextField("Address", text: $address)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.bottom, 10)
                                TextField("County", text: $county)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.bottom, 10)
                            }

                            TextField("Your Name", text: $fullName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 10)

                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(.bottom, 10)

                            TextField("Description of Issue", text: $issueDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(height: 100)
                                .padding(.bottom, 15)
                        }
                        .padding(.horizontal)

                        // Photo Selection
                        VStack(alignment: .leading) {
                            Text("Add Photos")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            PhotosPicker(selection: $selectedPhotos,
                                       maxSelectionCount: 5,
                                       matching: .images) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                    Text("Select Photos")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                            .padding(.horizontal)
                            
                            // Photo Preview Grid
                            if !selectedPhotoData.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(selectedPhotoData, id: \.self) { photoData in
                                            if let uiImage = UIImage(data: photoData) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .frame(height: 120)
                            }
                        }
                        .padding(.bottom, 15)

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                        }

                        // Submit Button
                        if isSubmitting {
                            ProgressView("Submitting...")
                                .padding()
                        } else {
                            Button(action: submitIssue) {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("Submit Issue")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    isFormValid()
                                        ? LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                            .disabled(!isFormValid())
                            .padding(.horizontal)
                            .padding(.bottom, 15)
                        }

                        // Close Button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Close")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
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
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Your issue has been submitted successfully."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .onChange(of: selectedPhotos) { newItems in
                Task {
                    selectedPhotoData = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            selectedPhotoData.append(data)
                        }
                    }
                }
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

        // Create a new issue with the form data
        let newIssue = Issue(
            fullName: fullName,
            issueDescription: issueDescription,
            category: category,
            businessName: businessName.isEmpty ? nil : businessName,
            address: address,
            county: county.isEmpty ? nil : county,
            email: email
        )

        // Submit the issue with photos
        firebaseService.addIssue(newIssue, photoData: selectedPhotoData.isEmpty ? nil : selectedPhotoData) { success in
            isSubmitting = false
            if success {
                showSuccessAlert = true
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
