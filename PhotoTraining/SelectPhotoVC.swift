import UIKit
import Photos

class SelectPhotoVC: UIViewController {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    private var imageAssets: [PHAsset]?
    private let itemSpace = CGFloat(5)
    private let layout = UICollectionViewFlowLayout()
    private var rowCount = 4
    private let cellWidth = CGFloat(90)
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthorization()
        setupPhotoCollection()
    }
    
    override func viewDidLayoutSubviews() {
        calculateRowCount(screenWidth: photosCollectionView.bounds.width)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        calculateRowCount(screenWidth: size.width)
        layout.invalidateLayout()
    }
    
    @objc func checkAuthorization() {
        let status =  PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            loadAssets()
        case .notDetermined:
            requestAuthorization()
        default:
            print("Other status")
        }
    }
    
    private func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
            if (status == .authorized || status == .limited) {
                self.loadAssets()
            } else {
                print("Not authorized")
            }
        }
    }
    
    private func loadAssets() {
        let ops = PHFetchOptions()
        ops.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        ops.predicate = NSPredicate(format: "pixelHeight BETWEEN {600, 6000} AND pixelWidth BETWEEN {800, 6000}")
        var assets = [PHAsset]()
        PHAsset.fetchAssets(with: .image, options: ops).enumerateObjects { (asset, _, _) in
            assets.append(asset)
            print("wid: \(asset.pixelWidth) height: \(asset.pixelHeight)")
        }
        imageAssets = assets
        DispatchQueue.main.async {
            if (self.refreshControl.isRefreshing) {
                self.refreshControl.endRefreshing()
            }
            self.photosCollectionView.reloadData()
        }
    }
    
    private func setupPhotoCollection() {
        layout.minimumInteritemSpacing = itemSpace
        photosCollectionView.collectionViewLayout = layout
        refreshControl.addTarget(self, action: #selector(checkAuthorization), for: .valueChanged)
        photosCollectionView.addSubview(refreshControl)
        photosCollectionView.alwaysBounceVertical = true
    }
    
    private func calculateRowCount(screenWidth: CGFloat) {
        if (screenWidth < cellWidth*4) {
            rowCount = 3
        } else {
            rowCount = 4
        }
    }
}

extension SelectPhotoVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageAssets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.configure(imageAssets?[indexPath.item])
        return cell
    }
    
}

extension SelectPhotoVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - CGFloat(rowCount) * itemSpace) / CGFloat(rowCount)
        return CGSize(width: width, height: width)
    }
}

