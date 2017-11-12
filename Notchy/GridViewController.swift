/*
 See LICENSE.txt for this sample’s licensing information.

 Abstract:
 Manages the second-level collection view, a grid of photos in a collection (or all photos).
 */

import UIKit
import Photos
import SuperLayout
import PhotosUI

protocol GridViewControllerDelegate: class {
    func gridViewControllerUpdatedAsset(_ asset: PHAsset)
}

extension PHAsset {
    static var screenshots: PHFetchResult<PHAsset> {
        let screenshotsAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil)
        let collection = screenshotsAlbum.object(at: 0)
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "pixelWidth == %@ AND pixelHeight == %@", argumentArray: [1125, 2436])
        return fetchAssets(in: collection, options: options)
    }
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

let CellIdentifier = "GridViewCellIdentifier"
final class GridViewController: UICollectionViewController {
    weak var gridViewControllerDelegate: GridViewControllerDelegate!
    var fetchResult: PHFetchResult<PHAsset>!

    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    private var gradientView: NotchyGradientView!

    // MARK: - UIViewController / Lifecycle

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }

    convenience init(delegate: GridViewControllerDelegate) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())

        gridViewControllerDelegate = delegate
        fetchResult = PHAsset.screenshots
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Screenshots"

        extendedLayoutIncludesOpaqueBars = true

        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)

        guard let collectionView = collectionView else {
            return
        }

        if let navigationBar = navigationController?.navigationBar {
            navigationBar.isTranslucent = false
            navigationBar.barStyle = .default
            navigationBar.barTintColor = .white
        }

        collectionView.bounces = true
        collectionView.backgroundColor = UIColor(0xe9e9e9)
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(GridViewCell.self, forCellWithReuseIdentifier: CellIdentifier)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateItemSize()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        updateItemSize()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }

    private func updateItemSize() {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        let viewWidth = view.bounds.size.width
        let columns: CGFloat = 4
        let padding: CGFloat = 10
        let itemWidth = floor((viewWidth - (columns - 1) * padding - 20) / columns)
        let aspect = CGFloat(2436) / CGFloat(1125)
        let itemHeight = itemWidth * aspect

        thumbnailSize = CGSize(width: itemWidth, height: itemHeight)

        layout.minimumLineSpacing = 10
        layout.itemSize = thumbnailSize

        // Determine the size of the thumbnails to request from the PHCachingImageManager
//        let scale = UIScreen.main.scale
//        thumbnailSize = CGSize(width: 1125 / scale, height: 2436 / scale)
    }
}

// MARK: - UICollectionView
extension GridViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = fetchResult.object(at: indexPath.item)
        gridViewControllerDelegate.gridViewControllerUpdatedAsset(asset)
        dismiss(animated: true, completion: nil)
    }

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
