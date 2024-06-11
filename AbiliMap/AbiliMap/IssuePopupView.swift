import SwiftUI
import FirebaseFirestore
import CoreLocation

struct IssuePopupView: View {
    @Binding var showPopup: Bool
    @State private var issueDescription = ""
    @State private var selectedImage: UIImage?
    @State private var userLocation: CLLocation?

    let locationManager = LocationManager()
    var currentUserId: String

    var body: some View {
        VStack {
            Text("Report an Issue")
                .font(.title)

            TextField("Issue Description", text: $issueDescription)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Take Photo") {
                // Handle image capture
                // For simplicity, using a placeholder image
                selectedImage = UIImage(systemName: "camera.fill")
            }
            .padding()

            HStack {
                Button("Close") {
                    self.showPopup.toggle()
                }
                .padding()

                Button("Submit") {
                    // Handle issue submission
                    saveIssueToFirebase()
                    self.showPopup.toggle()
                }
                .padding()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .onAppear {
            // Request user's location when the popup appears
            locationManager.requestLocation { location in
                self.userLocation = location
            }
        }
    }

    func saveIssueToFirebase() {
        guard !issueDescription.isEmpty,
              let userLocation = userLocation else {
            print("Incomplete data")
            return
        }

        let data: [String: Any] = [
            "issueDescription": issueDescription,
            "location": GeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude),
            "userId": currentUserId,
            "status": "pending"
        ]

        let db = Firestore.firestore()
        let issuesRef = db.collection("issues")
        issuesRef.addDocument(data: data) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added successfully")
            }
        }
    }
}
