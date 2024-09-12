import Foundation

// MARK: - Constants

enum Const {
    
    static let accessKey = "your_access_key"
    static let baseEndpoint = "https://api.unsplash.com"
    static let searchPhotosPath = "/search/photos"
    static let getPhotoByIdPath = "/photos/"
    
    static let query = "query"
    static let page = "page"
    static let perPage = "per_page"
    static let orderBy = "order_by"
    static let clientId = "client_id"
    
    static let firstPage = 1
    static let limitThirty = 30
    
    static let spacingSmall: CGFloat = 8
    static let spacingMedium: CGFloat = 16
    static let collectionCellCornerRadius: CGFloat = 15
    
    static let repeatButtonBorderWidth: CGFloat = 1
    static let repeatButtonCornerRadius: CGFloat = 10
    
    static let sortIcon = "arrow.up.arrow.down.circle"
    static let twoColumnsGridIcon = "square.grid.2x2"
    static let oneColumnGridIcon = "rectangle.grid.1x2"
    static let searchBarPlaceholder = "Search for inspiration..."
    static let imagePlaceholder = "photo"
    static let locationsKeyPath = "locations"
    static let shimmerAnimationKey = "shimmerAnimation"
    static let photoCollectionViewCellReuseIdentifier = "photoCell"
    static let photoCollectionViewFooterReuseIdentifier = "photoCellFooterView"
    static let searchHistoryCellReuseIdentifier = "searchHistoryCell"
    static let tryAgainTitle = "Try Again"
    static let loadingTitle = "Loading..."
    static let emptyDataTitle = "No data available."
    
    static let recentSearchesStorageKey = "recentSearches"
    static let maxRecentSearches = 5
}
