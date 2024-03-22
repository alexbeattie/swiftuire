import SwiftUI

struct CachedAsyncImage<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Placeholder
    private let image: (Image) -> Image
    
    init(
        url: URL?,
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder image: @escaping (Image) -> Image = { $0 }
    ) {
        self.placeholder = placeholder()
        self.image = image
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }
    
    var body: some View {
        content
            .onAppear(perform: loader.load)
    }
    
    private var content: some View {
        Group {
            if loader.image != nil {
                image(Image(uiImage: loader.image!))
            } else {
                placeholder
            }
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private(set) var isLoading = false
    private let url: URL?
    private var cache: ImageCache?
    
    init(url: URL?, cache: ImageCache?) {
        self.url = url
        self.cache = cache
    }
    
    func load() {
        guard !isLoading else { return }
        
        if let image = cache?[url] {
            self.image = image
            return
        }
        
        isLoading = true
        
        guard let url = url else {
            isLoading = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            
            if let data = data, let image = UIImage(data: data) {
                self.cache?[url] = image
                DispatchQueue.main.async {
                    self.image = image
                }
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        task.resume()
    }
}

protocol ImageCache {
    subscript(_ url: URL?) -> UIImage? { get set }
}

struct TemporaryImageCache: ImageCache {
    private let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()
    
    subscript(_ key: URL?) -> UIImage? {
        get { cache.object(forKey: key! as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key! as NSURL) : cache.setObject(newValue!, forKey: key! as NSURL) }
    }
}

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
