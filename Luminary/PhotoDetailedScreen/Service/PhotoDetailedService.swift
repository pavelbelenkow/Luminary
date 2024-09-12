import Foundation
import Combine

// MARK: - Protocols

protocol PhotoDetailedServiceProtocol {
    func fetchPhoto(by id: String) -> AnyPublisher<Photo, Error>
}

final class PhotoDetailedService {
    
    // MARK: - Private Properties
    
    private let networkClient: NetworkClientProtocol
    private let decoder: JSONDecoder
    
    // MARK: - Initialisers
    
    init(
        networkClient: NetworkClientProtocol = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.networkClient = networkClient
        self.decoder = decoder
    }
}

// MARK: - PhotoDetailedServiceProtocol Methods

extension PhotoDetailedService: PhotoDetailedServiceProtocol {
    
    func fetchPhoto(by id: String) -> AnyPublisher<Photo, Error> {
        let request = PhotoRequest(id: id)
        
        guard let urlRequest = request.makeURLRequest() else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return networkClient
            .performRequest(with: urlRequest)
            .decode(type: Photo.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
