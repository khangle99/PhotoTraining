import UIKit
import Photos

class PhotoCell: UICollectionViewCell {
 
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var alertImageView: UIImageView!
    
    func configure(_ asset: PHAsset?) {
        guard let asset = asset else {
            return
        }
        invalidateAlert(asset)
        let width = photoImageView.bounds.width
        let opts = PHImageRequestOptions()
        opts.resizeMode = .fast
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: width, height: width), contentMode: .aspectFit, options: opts) { (img, _) in
            self.photoImageView.image = img
        }
    }
    
    private func invalidateAlert(_ asset: PHAsset) {
        if (asset.pixelWidth < 1024 || asset.pixelHeight < 768) {
            alertImageView.alpha = 1
        } else {
            alertImageView.alpha = 0
        }
    }
    
}
