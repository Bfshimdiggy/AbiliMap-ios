import SwiftUI
import CoreLocation
import Firebase

struct IssuePopupView: View {
    @Binding var showPopup: Bool
    @State private var issueDescription = ""
    @State private var selectedImage: UIImage?
    @State private var userLocation: CLLocation?
    
    let locationManager = LocationManager()
    let userId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    
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
              let selectedImage = self.selectedImage,
              let userLocation = self.userLocation else {
            print("Incomplete data")
            return
        }
        
        let data: [String: Any] = [
            "issueDescription": issueDescription,
            "location": GeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude),
            "userId": userId,
            "status": "pending"
        ]
        
        // Convert UIImage to Data
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }
        
        // Upload image data directly to Firestore as base64 encoded string
        let imageBase64String = imageData.base64EncodedString()
        var dataWithImage = data
        dataWithImage["imageBase64"] = imageBase64String
        
        let db = Firestore.firestore()
        let issuesRef = db.collection("issues")
        issuesRef.addDocument(data: dataWithImage) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added successfully")
            }
        }
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation(completion: @escaping (CLLocation?) -> Void) {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        self.completion = completion
    }
    
    var completion: ((CLLocation?) -> Void)?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            NotificationCenter.default.post(name: NSNotification.Name("LocationUpdated"), object: location)
            completion?(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
        completion?(nil)
    }
}
