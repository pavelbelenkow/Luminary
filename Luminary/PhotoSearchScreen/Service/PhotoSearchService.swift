import Foundation
import Combine

// MARK: - Protocols

protocol PhotoSearchServiceProtocol {
    func searchPhotos(query: String, page: Int, perPage: Int, sortBy: String) -> AnyPublisher<[Photo], Error>
}

final class PhotoSearchService {
    
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

// MARK: - PhotoSearchServiceProtocol Methods

extension PhotoSearchService: PhotoSearchServiceProtocol {
    
    func searchPhotos(
        query: String,
        page: Int = Const.firstPage,
        perPage: Int = Const.limitThirty,
        sortBy: String
    ) -> AnyPublisher<[Photo], any Error> {
        let request = PhotoSearchRequest(
            query: query,
            page: page,
            perPage: perPage,
            sortBy: sortBy
        )
        
        guard let urlRequest = request.makeURLRequest() else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return networkClient
            .performRequest(with: urlRequest)
            .decode(type: PhotoSearchResult.self, decoder: decoder)
            .map { $0.results }
            .eraseToAnyPublisher()
    }
}
