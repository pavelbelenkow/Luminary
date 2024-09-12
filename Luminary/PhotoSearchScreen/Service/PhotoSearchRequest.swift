import Foundation

struct PhotoSearchRequest: NetworkRequest {
    let query: String
    let page: Int
    let perPage: Int
    let sortBy: String
    
    var path: String { Const.searchPhotosPath }
    var parameters: [(String, Any)] {
        var parameters: [(String, Any)] = []
        
        parameters.append((Const.query, query))
        parameters.append((Const.page, String(page)))
        parameters.append((Const.perPage, String(perPage)))
        parameters.append((Const.orderBy, sortBy))
        parameters.append((Const.clientId, Const.accessKey))
        
        return parameters
    }
}
