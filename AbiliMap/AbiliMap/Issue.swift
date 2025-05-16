import FirebaseFirestore

struct Issue: Identifiable, Codable {
    var id: String
    var fullName: String
    var issueDescription: String
    var category: String
    var businessName: String?
    var address: String
    var county: String?
    var email: String?
    var photoURLs: [String]? // Array of photo URLs

    // Default initializer for creating an Issue object
    init(id: String = UUID().uuidString,
         fullName: String,
         issueDescription: String,
         category: String,
         businessName: String? = nil,
         address: String,
         county: String? = nil,
         email: String? = nil,
         photoURLs: [String]? = nil) {
        self.id = id
        self.fullName = fullName
        self.issueDescription = issueDescription
        self.category = category
        self.businessName = businessName
        self.address = address
        self.county = county
        self.email = email
        self.photoURLs = photoURLs
    }

    // Add a failable initializer to handle Firebase data parsing
    init?(from data: [String: Any]) {
        guard let id = data["id"] as? String,
              let fullName = data["fullName"] as? String,
              let issueDescription = data["issueDescription"] as? String,
              let category = data["category"] as? String,
              let address = data["address"] as? String else {
            return nil // Return nil if any required field is missing
        }

        self.id = id
        self.fullName = fullName
        self.issueDescription = issueDescription
        self.category = category
        self.businessName = data["businessName"] as? String
        self.address = address
        self.county = data["county"] as? String
        self.email = data["email"] as? String
        self.photoURLs = data["photoURLs"] as? [String]
    }

    // A dictionary representation of the Issue, for Firebase
    var dictionary: [String: Any] {
        return [
            "id": id,
            "fullName": fullName,
            "issueDescription": issueDescription,
            "category": category,
            "businessName": businessName ?? "",
            "address": address,
            "county": county ?? "",
            "email": email ?? "",
            "photoURLs": photoURLs ?? []
        ]
    }
}
