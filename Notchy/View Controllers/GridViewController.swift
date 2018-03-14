/*
 See LICENSE.txt for this sample’s licensing information.

 Abstract:
 Manages the second-level collection view, a grid of photos in a collection (or all photos).
 */

import UIKit
import Photos
import SuperLayout
import PhotosUI
import GameplayKit
import Hero
import Presentr
import LionheartExtensions
import SwiftyUserDefaults

protocol GridViewControllerDelegate: class {
    func gridViewControllerUpdatedAsset(_ asset: PHAsset)
}

extension PHAsset {
    static var screenshots: PHFetchResult<PHAsset> {
        let album = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        let collection = album.object(at: 0)
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

final class GridViewController: UICollectionViewController, ExtraStuffPresentationDelegate {
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()

    weak var gridViewControllerDelegate: GridViewControllerDelegate?
    var fetchResult: PHFetchResult<PHAsset>!

    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero

    lazy var extraStuffPresenter = ExtraStuffViewController.presenter(view: view)
    lazy var iconSelectorPresenter = IconSelectorViewController.presenter(view: view)

    // MARK: - Initializers

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }

    convenience init(delegate: GridViewControllerDelegate? = nil) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())

        gridViewControllerDelegate = delegate
        fetchResult = PHAsset.screenshots
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    // MARK: - View Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        extendedLayoutIncludesOpaqueBars = true

        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)

        #if SHOW_ALTERNATE_ICONS_IN_IAP
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Icons"), style: .plain, target: self, action: #selector(rightBarButtonItemDidTouchUpInside(_:)))
            navigationItem.rightBarButtonItem?.tintColor = .black
        #endif

        guard let collectionView = collectionView else {
            return
        }

        let refresh = UIRefreshControl()
        refresh.tintColor = .white
        refresh.addTarget(self, action: #selector(refreshControlValueChanged(_:)), for: .valueChanged)
        collectionView.refreshControl = refresh

        collectionView.bounces = true
        collectionView.backgroundColor = UIColor(0x2a2f33)
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(GridViewCell.self)
    }

    @objc func rightBarButtonItemDidTouchUpInside(_ sender: Any) {
        if UserDefaults.purchased {
            let controller = IconSelectorViewController(delegate: self)
            controller.transitioningDelegate = iconSelectorPresenter
            controller.modalPresentationStyle = .custom
            present(controller, animated: true, completion: nil)
        } else {
            showIAPModal()
        }
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

    // MARK: - Misc

    @objc func refreshControlValueChanged(_ sender: Any) {
        guard let refresh = sender as? UIRefreshControl else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.collectionView?.reloadData()
            refresh.endRefreshing()
        }
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
    }
}

// MARK: - UICollectionView
extension GridViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = fetchResult.object(at: indexPath.item)

        let manager = PHImageManager.default()
        manager.image(asset: asset) { [unowned self] (theImage) in
            guard let theImage = theImage else {
                return
            }

            let controller = SingleImageViewController(asset: asset, original: theImage, masked: theImage)
            self.present(controller, animated: true)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as GridViewCell
        let asset = fetchResult.object(at: indexPath.item)

        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.imageView.heroID = asset.localIdentifier

        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            guard cell.representedAssetIdentifier == asset.localIdentifier && image != nil else {
                return
            }

            if Defaults[.identifiers].contains(asset.localIdentifier) {
                cell.thumbnailImage = image?.maskv1(watermark: false)
            } else {
                cell.thumbnailImage = image
            }
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

// From Apple Sample Code
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

// MARK: - IconSelectorViewControllerDelegate
extension GridViewController: IconSelectorViewControllerDelegate {
    func showIAPModal() {
        let controller = ExtraStuffViewController()
        controller.transitioningDelegate = extraStuffPresenter
        controller.modalPresentationStyle = .custom
        present(controller, animated: true)
    }
}
