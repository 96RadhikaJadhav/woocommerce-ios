import Photos
import Yosemite

/// Provides an image for UI display based on the product image status.
///
final class ProductImagesProvider {
    private var imagesByProductImageID: [Int64: UIImage] = [:]
    private let imageService: ImageService

    init(imageService: ImageService = ServiceLocator.imageService) {
        self.imageService = imageService
    }

    func requestImage(productImage: ProductImage, completion: @escaping (UIImage) -> Void) {
        if let image = imagesByProductImageID[productImage.imageID] {
            completion(image)
            return
        }
        guard let url = URL(string: productImage.src) else {
            return
        }
        imageService.downloadImage(with: url, shouldCacheImage: true) { [weak self] (image, error) in
            guard let image = image else {
                return
            }
            self?.imagesByProductImageID[productImage.imageID] = image
            completion(image)
        }
    }

    func requestImage(asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage) -> Void) {
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil) { (image, info) in
            guard let image = image else {
                return
            }
            completion(image)
        }
    }

    /// Called when an asset has been uploaded to generate an image for UI display.
    /// - Parameters:
    ///   - asset: the asset that has just been uploaded.
    ///   - productImage: the remote product image.
    ///
    func update(from asset: PHAsset, to productImage: ProductImage) {
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil) { [weak self] (image, info) in
            guard let image = image else {
                return
            }
            self?.imagesByProductImageID[productImage.imageID] = image
        }
    }
}
