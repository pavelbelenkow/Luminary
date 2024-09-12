import Foundation

// MARK: - Protocols

protocol SearchHistoryStorageProtocol {
    var recentSearches: [String] { get }
    func addSearchQuery(_ query: String)
}

final class SearchHistoryStorage: SearchHistoryStorageProtocol {
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Properties
    
    var recentSearches: [String] {
        userDefaults.stringArray(forKey: Const.recentSearchesStorageKey) ?? []
    }
    
    // MARK: - Initialisers
    
    init() {}
    
    // MARK: - Methods
    
    func addSearchQuery(_ query: String) {
        var searches = recentSearches
        
        if let index = searches.firstIndex(of: query) {
            searches.remove(at: index)
        }
        
        if searches.count == Const.maxRecentSearches {
            searches.removeLast()
        }
        
        searches.insert(query, at: .zero)
        userDefaults.set(searches, forKey: Const.recentSearchesStorageKey)
    }
}
