import SwiftUI
import FirebaseFirestore
import CoreLocation

struct ContentView: View {
    @State private var showPopup = false
    @State private var currentUserId: String?
    @State private var isAdmin = false

    let adminUserIds = ["E779E3F7-C217-4CBC-8A3B-98A07ADB9DE8"] // Replace with admin user IDs

    var body: some View {
        NavigationView {
            VStack {
                Text("Click the + to report an issue")
                    .font(.title)
                    .padding()

                if let userId = currentUserId {
                    Button(action: {
                        self.showPopup.toggle()
                    }) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    .padding()

                    if isAdmin {
                        NavigationLink(destination: AdminView()) {
                            Text("View Pending Issues")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    Text("Loading user data...")
                }

                Spacer()
            }
            .sheet(isPresented: $showPopup) {
                if let userId = currentUserId {
                    IssuePopupView(showPopup: self.$showPopup, currentUserId: userId)
                }
            }
            .onAppear {
                setupUserId()
            }
        }
    }

    private func setupUserId() {
        // Check if a user ID exists in UserDefaults
        if let savedUserId = UserDefaults.standard.string(forKey: "userId") {
            currentUserId = savedUserId
        } else {
            // Generate a new user ID and save it to UserDefaults
            let newUserId = UUID().uuidString
            UserDefaults.standard.set(newUserId, forKey: "userId")
            currentUserId = newUserId
        }

        // Check if the current user is an admin
        if let userId = currentUserId, adminUserIds.contains(userId) {
            isAdmin = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
