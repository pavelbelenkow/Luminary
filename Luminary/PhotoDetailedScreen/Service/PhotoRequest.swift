import Foundation

struct PhotoRequest: NetworkRequest {
    let id: String
    
    var path: String { Const.getPhotoByIdPath + id }
    var parameters: [(String, Any)] {
        [(Const.clientId, Const.accessKey)]
    }
}
