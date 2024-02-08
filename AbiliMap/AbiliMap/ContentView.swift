import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var showPopup = false

    var body: some View {
        VStack {
            Text("Click the + to report an issue")
                .font(.title)
                .padding()

            Button(action: {
                self.showPopup.toggle()
            }) {
                Image(systemName: "plus.circle")
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            .padding()

            Spacer()
        }
        .sheet(isPresented: $showPopup) {
            IssuePopupView(showPopup: self.$showPopup)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct IssuePopupView: View {
    @Binding var showPopup: Bool
    @State private var issueDescription = ""
    @State private var selectedImage: UIImage?
    @State private var userLocation: CLLocation?
    
    let locationManager = LocationManager()
    
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
                    // Handle issue submission (e.g., print to console)
                    print("Issue Description: \(issueDescription)")
                    if selectedImage != nil {
                        // Handle image
                        print("Image captured")
                    }
                    if let location = userLocation {
                        // Handle location
                        print("User Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    } else {
                        print("Location not available")
                    }
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

