//
//  RequestAccessViewController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/6/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import Photos

final class RequestAccessViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .notDetermined, .restricted, .denied:
                let alert = UIAlertController(title: "Photo Library Inaccessible", message: "Notchy couldn't read your photo library.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)

            case .authorized:
                let screenshotsAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil)
                let collection = screenshotsAlbum.object(at: 0)
                let layout = UICollectionViewFlowLayout()
                let gridViewController = GridViewController(collectionViewLayout: layout)
                gridViewController.fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
                gridViewController.assetCollection = collection

                let navigation = UINavigationController(rootViewController: gridViewController)
                self.present(navigation, animated: false, completion: nil)
            }
        }
    }
}
