import UIKit
import Yosemite

final class ProductImagesViewModel {
    
    private(set) var product: Product
    
    var items: [ProductImagesItem] = []
    
    init(product: Product) {
        self.product = product
        
        configureItems()
    }
    
    func configureItems() {
        items = []
        for _ in product.images {
            items.append(.image)
        }
        
        items.append(.addImage)
    }
}


// MARK: - Register collection view cells
//
extension ProductImagesViewModel {
    /// Registers all of the available CollectionViewCells
    ///
    func registerCollectionViewCells(_ collectionView: UICollectionView) {
        let cells = [
            ProductImageCollectionViewCell.self,
            AddProductImageCollectionViewCell.self
        ]

        for cell in cells {
            collectionView.register(cell.loadNib(), forCellWithReuseIdentifier: cell.reuseIdentifier)
        }
    }
}
