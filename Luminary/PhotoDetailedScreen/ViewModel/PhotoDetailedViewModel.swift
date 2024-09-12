import Combine

// MARK: - Protocols

protocol PhotoDetailedViewModelProtocol: ObservableObject {
    var stateSubject: CurrentValueSubject<State, Never> { get }
    var photoSubject: PassthroughSubject<Photo, Never> { get }
    var cancellables: Set<AnyCancellable> { get set }
    
    func loadPhotoDetail()
}

final class PhotoDetailedViewModel: PhotoDetailedViewModelProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var stateSubject: CurrentValueSubject<State, Never> = .init(.idle)
    private(set) var photoSubject: PassthroughSubject<Photo, Never> = .init()
    
    // MARK: - Private Properties
    
    private let photoId: String
    private let photoDetailedService: PhotoDetailedServiceProtocol
    
    // MARK: - Properties
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    init(photoId: String, service: PhotoDetailedServiceProtocol = PhotoDetailedService()) {
        self.photoId = photoId
        self.photoDetailedService = service
    }
    
    // MARK: - Deinitializers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Methods
    
    func loadPhotoDetail() {
        stateSubject.send(.loading)
        
        photoDetailedService
            .fetchPhoto(by: photoId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        stateSubject.send(.error(error.localizedDescription))
                    }
                },
                receiveValue: { [weak self] photoDetail in
                    guard let self else { return }
                    
                    photoSubject.send(photoDetail)
                    stateSubject.send(.loaded)
                }
            )
            .store(in: &cancellables)
    }
}
