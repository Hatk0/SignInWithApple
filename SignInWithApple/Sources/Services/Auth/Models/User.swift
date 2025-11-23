import Foundation

struct User: Codable {
    let id: String
    let email: String?
    let fullName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email, fullName
    }
}
