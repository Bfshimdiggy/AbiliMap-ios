import SwiftUI
import FirebaseFirestore


struct Issue: Identifiable, Codable {
    @DocumentID var id: String?
    var issueDescription: String
    var location: GeoPoint
    var userId: String
    var status: String
    var imageBase64: String
}

struct AdminView: View {
    @State private var issues: [Issue] = []
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            List(issues) { issue in
                VStack(alignment: .leading) {
                    Text(issue.issueDescription)
                        .font(.headline)
                    Text("Location: \(issue.location.latitude), \(issue.location.longitude)")
                        .font(.subheadline)
                    Text("Status: \(issue.status)")
                        .font(.subheadline)
                    Text("User ID: \(issue.userId)")
                        .font(.subheadline)
                }
            }
            .navigationTitle("Pending Issues")
            .onAppear {
                fetchPendingIssues()
            }
        }
    }

    func fetchPendingIssues() {
        let db = Firestore.firestore()
        db.collection("issues")
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = "Error fetching issues: \(error.localizedDescription)"
                    print(self.errorMessage)
                    return
                }
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No issues found"
                    print(self.errorMessage)
                    return
                }
                print("Documents fetched: \(documents.count)")
                self.issues = documents.compactMap { document -> Issue? in
                    let result = Result { try document.data(as: Issue.self) }
                    switch result {
                    case .success(let issue):
                        return issue
                    case .failure(let error):
                        print("Error decoding issue: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
    }
}

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
    }
}
