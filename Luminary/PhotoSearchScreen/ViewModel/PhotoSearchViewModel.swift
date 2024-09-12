import Foundation
import Combine

// MARK: - Protocols

protocol PhotoSearchViewModelProtocol: ObservableObject {
    var stateSubject: CurrentValueSubject<State, Never> { get }
    var photosSubject: CurrentValueSubject<[Photo], Never> { get }
    var searchBarTextSubject: PassthroughSubject<String, Never> { get }
    var recentSearchesSubject: CurrentValueSubject<[String], Never> { get }
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func searchPhotos()
    func loadMorePhotos()
    func changeSortType()
    func setSearchQuery(for text: String)
    func filterSuggestions(for searchText: String?)
    func didSelectSearchQuery(at index: Int)
}

final class PhotoSearchViewModel: PhotoSearchViewModelProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var stateSubject: CurrentValueSubject<State, Never> = .init(.idle)
    private(set) var photosSubject: CurrentValueSubject<[Photo], Never> = .init([])
    private(set) var searchBarTextSubject: PassthroughSubject<String, Never> = .init()
    private(set) var recentSearchesSubject: CurrentValueSubject<[String], Never> = .init([])
    
    // MARK: - Private Properties
    
    private var searchQuery: String = ""
    private var currentPage: Int = 1
    private var hasMorePages: Bool = true
    private var limit: Int = Const.limitThirty
    private var sortType: SortType = .relevant
    
    private let photoSearchService: PhotoSearchServiceProtocol
    private let searchHistoryStorage: SearchHistoryStorageProtocol
    
    // MARK: - Properties
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    init(
        service: PhotoSearchServiceProtocol = PhotoSearchService(),
        storage: SearchHistoryStorageProtocol = SearchHistoryStorage()
    ) {
        self.photoSearchService = service
        self.searchHistoryStorage = storage
    }
    
    // MARK: - Deinitializers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Private Methods
    
    private func resetPagination() {
        currentPage = 1
        hasMorePages = true
        photosSubject.send([])
    }
    
    // MARK: - Methods
    
    func searchPhotos() {
        guard
            stateSubject.value != .loading,
            hasMorePages,
            !searchQuery.isEmpty
        else { return }
        
        let isPaginating = currentPage > 1
        stateSubject.send(isPaginating ? .loadingMore : .loading)
        
        photoSearchService
            .searchPhotos(
                query: searchQuery,
                page: currentPage,
                perPage: limit,
                sortBy: sortType.rawValue
            )
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let failure):
                        stateSubject.send(.error(failure.localizedDescription))
                    }
                }, receiveValue: { [weak self] newPhotos in
                    guard let self else { return }
                    
                    let filteredPhotos = newPhotos.filter { $0.description != nil }
                    
                    if currentPage == 1 {
                        photosSubject.send(filteredPhotos)
                    } else {
                        let allPhotos = photosSubject.value + filteredPhotos
                        photosSubject.send(allPhotos)
                    }
                    
                    stateSubject.send(photosSubject.value.isEmpty ? .empty : .loaded)
                    hasMorePages = newPhotos.count == limit
                })
            .store(in: &cancellables)
    }
    
    func loadMorePhotos() {
        guard
            stateSubject.value != .loading,
            stateSubject.value != .loadingMore,
            hasMorePages
        else { return }
        
        currentPage += 1
        searchPhotos()
    }
    
    func changeSortType() {
        sortType = sortType == .relevant ? .latest : .relevant
        resetPagination()
        searchPhotos()
    }
    
    func setSearchQuery(for text: String) {
        guard !text.isEmpty, text != searchQuery else { return }
        
        searchQuery = text
        searchHistoryStorage.addSearchQuery(text)
        recentSearchesSubject.send(searchHistoryStorage.recentSearches)
        
        resetPagination()
        searchPhotos()
    }
    
    func filterSuggestions(for searchText: String?) {
        guard
            let searchText,
            !searchText.isEmpty
        else {
            recentSearchesSubject.send(searchHistoryStorage.recentSearches)
            return
        }
        
        let filteredSuggestions = recentSearchesSubject.value.filter {
            $0.localizedCaseInsensitiveContains(searchText)
        }
        
        recentSearchesSubject.send(filteredSuggestions)
    }
    
    func didSelectSearchQuery(at index: Int) {
        let selectedRecentSearch = recentSearchesSubject.value[index]
        searchBarTextSubject.send(selectedRecentSearch)
        setSearchQuery(for: selectedRecentSearch)
    }
}
