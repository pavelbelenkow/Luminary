import UIKit

final class PhotoLoader {
    
    // MARK: - Static Properties
    
    static let shared = PhotoLoader()
    
    // MARK: - Private Properties
    
    private let placeholder = UIImage(systemName: Const.imagePlaceholder)
    private let cache = NSCache<NSString, UIImage>()
    private let photoLoadingQueue = DispatchQueue(label: "photoLoader.queue", qos: .userInitiated)
    private var photoDataTask: URLSessionDataTask?
    
    private let session: URLSession
    
    // MARK: - Private Initialisers
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Methods
    
    func loadPhoto(
        from urlString: String,
        completion: @escaping (UIImage?) -> Void
    ) {
        photoLoadingQueue.async { [weak self] in
            guard let self else { return }
            
            if let cachedImage = cache.object(forKey: NSString(string: urlString)) {
                DispatchQueue.main.async {
                    completion(cachedImage)
                }
                return
            }
            
            guard let url = URL(string: urlString) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let request = URLRequest(url: url)
            
            photoDataTask = session.dataTask(with: request) { [weak self] data, response, error in
                guard let self else { return }
                photoDataTask = nil
                
                guard
                    let data,
                    let image = UIImage(data: data),
                    error == nil
                else {
                    DispatchQueue.main.async { [weak self] in
                        completion(self?.placeholder)
                    }
                    return
                }
                
                cache.setObject(image, forKey: NSString(string: urlString))
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            
            photoDataTask?.resume()
        }
    }
    
    func cancelLoading() {
        photoDataTask?.cancel()
    }
}
