/*
 See LICENSE.txt for this sample’s licensing information.

 Abstract:
 Manages the second-level collection view, a grid of photos in a collection (or all photos).
 */

import UIKit
import Photos
import SuperLayout
import PhotosUI

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

let CellIdentifier = "GridViewCellIdentifier"
final class GridViewController: UICollectionViewController {
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!

    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    private var toolbar: UIView!
    private var notchifyButton: RoundedButton!
    private var deleteOriginalLabel: UILabel!
    private var deleteOriginalSwitch: UISwitch!
    private var statusBarBackground: UIView!

    // MARK: - UIViewController / Lifecycle

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }

    convenience init() {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())

        let screenshotsAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil)
        let collection = screenshotsAlbum.object(at: 0)
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "pixelWidth == %@ AND pixelHeight == %@", argumentArray: [1125, 2436])

        fetchResult = PHAsset.fetchAssets(in: collection, options: options)
        assetCollection = collection
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        title = "[Notchy Logo]"

        let logoImage = UIImage(named: "Logo")!
        let imageView = UIImageView(image: logoImage)
        imageView.contentMode = .top
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let navigationBar = UINavigationBar()
        navigationBar.backgroundColor = .clear
        navigationBar.isHidden = true
        navigationBar.translatesAutoresizingMaskIntoConstraints = false

        statusBarBackground = UIView()
        statusBarBackground.backgroundColor = .clear
        statusBarBackground.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(statusBarBackground)
//        view.addSubview(navigationBar)

        statusBarBackground.topAnchor ~~ view.topAnchor
        statusBarBackground.leadingAnchor ~~ view.leadingAnchor
        statusBarBackground.trailingAnchor ~~ view.trailingAnchor
        statusBarBackground.bottomAnchor ~~ view.safeAreaLayoutGuide.topAnchor + 44

//        navigationBar.topAnchor ~~ view.safeAreaLayoutGuide.topAnchor
//        navigationBar.leadingAnchor ~~ view.leadingAnchor
//        navigationBar.trailingAnchor ~~ view.trailingAnchor
//        navigationBar.heightAnchor ~~ 44

        // 424x126

//        navigationItem.titleView = imageView
//        imageView.heightAnchor ~~ 63
//        imageView.widthAnchor ~~ 212

        toolbar = UIView()
        toolbar.backgroundColor = .white
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        deleteOriginalLabel = UILabel()
        deleteOriginalLabel.text = "Delete Original?"

        deleteOriginalSwitch = UISwitch()
        deleteOriginalSwitch.isOn = true

        let deleteOriginalStackView = UIStackView(arrangedSubviews: [deleteOriginalLabel, deleteOriginalSwitch])
        deleteOriginalStackView.translatesAutoresizingMaskIntoConstraints = false
        deleteOriginalStackView.axis = .horizontal
        deleteOriginalStackView.spacing = 15
        deleteOriginalStackView.isHidden = true

        notchifyButton = RoundedButton(color: UIColor(0xE74C3B), textColor: .white, padding: 0)
        notchifyButton.translatesAutoresizingMaskIntoConstraints = false
        notchifyButton.setTitle("Notchify!", for: .normal)

        let toolbarStackView = UIStackView(arrangedSubviews: [notchifyButton, deleteOriginalStackView])
        toolbarStackView.translatesAutoresizingMaskIntoConstraints = false
        toolbarStackView.axis = .vertical
        toolbarStackView.spacing = 10

        toolbar.addSubview(toolbarStackView)
        view.addSubview(toolbar)

        let margin: CGFloat = 15
        toolbar.topAnchor ~~ toolbarStackView.topAnchor - margin
        toolbarStackView.centerXAnchor ~~ toolbar.centerXAnchor
        toolbarStackView.bottomAnchor ~~ view.safeAreaLayoutGuide.bottomAnchor
        toolbar.bottomAnchor ~~ view.bottomAnchor
        toolbar.leadingAnchor ~~ view.leadingAnchor
        toolbar.trailingAnchor ~~ view.trailingAnchor

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = .white

        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)

        guard let collectionView = collectionView else {
            return
        }

        collectionView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: toolbar.frame.height, right: 0)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.register(GridViewCell.self, forCellWithReuseIdentifier: CellIdentifier)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Add button to the navigation bar if the asset collection supports adding content.
        if assetCollection == nil || assetCollection.canPerform(.addContent) {
            // MARK: TODO
//            navigationItem.rightBarButtonItem = addButtonItem
        } else {
            navigationItem.rightBarButtonItem = nil
        }

        updateItemSize()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        updateItemSize()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()

        let gradient = CAGradientLayer()
        gradient.frame = statusBarBackground.frame
        gradient.masksToBounds = true
        gradient.colors = [UIColor(0x4EC8ED).cgColor, UIColor(0x55C229).cgColor]

        statusBarBackground.layer.addSublayer(gradient)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? AssetViewController
            else { fatalError("unexpected view controller for segue") }
        guard let cell = sender as? UICollectionViewCell else { fatalError("unexpected sender") }

        if let indexPath = collectionView?.indexPath(for: cell) {
            destination.asset = fetchResult.object(at: indexPath.item)
        }
        destination.assetCollection = assetCollection
    }

    private func updateItemSize() {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        layout.minimumLineSpacing = 10

        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: 1125 / scale, height: 2436 / scale)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: 1125 / scale, height: 2436 / scale)
        let viewWidth = view.bounds.size.width
        let columns: CGFloat = 1
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let asset = fetchResult.object(at: indexPath.item)
        let aspect = CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth)
        let itemHeight = itemWidth * aspect
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

// MARK: - UICollectionView
extension GridViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! GridViewCell
        let asset = fetchResult.object(at: indexPath.item)

        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            guard cell.representedAssetIdentifier == asset.localIdentifier && image != nil else {
                return
            }

            cell.thumbnailImage = image
        }

        return cell
    }
}

// MARK: - UIScrollView
extension GridViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
}

// MARK: - Asset Caching
extension GridViewController {
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }

    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard view.window != nil && isViewLoaded else {
            return
        }

        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)

        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }

        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }

        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets, targetSize: thumbnailSize, contentMode: .aspectFit, options: nil)
        imageManager.stopCachingImages(for: removedAssets, targetSize: thumbnailSize, contentMode: .aspectFit, options: nil)

        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }

    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension GridViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let collectionView = collectionView else { fatalError() }

        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }

        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges

            guard changes.hasIncrementalChanges else {
                collectionView.reloadData()
                return
            }

            // If we have incremental diffs, animate them in the collection view.
            collectionView.performBatchUpdates({
                // For indexes to make sense, updates must be in this order:
                // delete, insert, reload, move
                let transform: (Int) -> IndexPath = {
                    return IndexPath(item: $0, section: 0)
                }

                if let removed = changes.removedIndexes, !removed.isEmpty {
                    collectionView.deleteItems(at: removed.map(transform))
                }

                if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                    collectionView.insertItems(at: inserted.map(transform))
                }

                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map(transform))
                }

                changes.enumerateMoves { fromIndex, toIndex in
                    collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                            to: IndexPath(item: toIndex, section: 0))
                }
            })

            resetCachedAssets()
        }
    }
}

extension GridViewController {
    func scrollToNearestItem() {
        guard let collectionView = collectionView else {
            return
        }

        let point = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x,
                            y: collectionView.center.y + collectionView.contentOffset.y + view.frame.height / 4)

        guard let indexPath = collectionView.indexPathForItem(at: point) else {
            return
        }

        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToNearestItem()
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
        scrollToNearestItem()
    }
}
