import Foundation

struct PhotoSearchResult: Decodable {
    let results: [Photo]
}

struct Photo: Decodable {
    let id: String
    let description: String?
    let user: User
    let urls: PhotoURLs
    
    private let uniqueIdentifier = UUID()
}

struct User: Decodable {
    let name: String
    let profileImage: ProfileImage
    
    private enum CodingKeys: String, CodingKey {
        case name
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Decodable {
    let small: String
    let medium: String
    let large: String
}

struct PhotoURLs: Decodable {
    let thumb: String?
    let small: String?
    let full: String?
}

extension Photo: Hashable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.uniqueIdentifier == rhs.uniqueIdentifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueIdentifier)
    }
}
