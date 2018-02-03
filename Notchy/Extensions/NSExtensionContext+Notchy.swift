//
//  NSExtensionContext+Notchy.swift
//  Notchy
//
//  Created by Dan Loewenherz on 2/3/18.
//  Copyright © 2018 Lionheart Software LLC. All rights reserved.
//

import UIKit

typealias JSONDictionary = [String: Any]

extension NSExtensionContext {
    func json(_ completion: @escaping (([JSONDictionary]) -> ())) {
        var itemsJSON: [JSONDictionary] = []
        
        guard let inputItems = inputItems as? [NSExtensionItem] else {
            completion([])
            return
        }
        
        var _attachments: [NSItemProvider] = []
        
        main: for item in inputItems {
            guard let attachments = item.attachments as? [NSItemProvider] else {
                continue
            }
            
            var attachmentsJSON: [String] = []
            for attachment in attachments {
                guard attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) else {
                    continue
                }
                
                _attachments.append(attachment)
            }
            
            var itemJSON: JSONDictionary = [
                "providers": attachmentsJSON
            ]
            
            if let userInfo = item.userInfo {
                var item: JSONDictionary = [:]
                for (key, value) in userInfo {
                    item[String(describing: key)] = String(describing: value)
                }
                itemJSON["item"] = item
            }
            
            itemsJSON.append(itemJSON)
        }
        
        let group = DispatchGroup()
        for attachment in _attachments {
            group.enter()
            attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (imageURL, error) in
                guard let _imageURL = imageURL as? URL,
                    let data = try? Data(contentsOf: _imageURL) else {
                        itemsJSON.append(["data": String(describing: imageURL)])
                        group.leave()
                        return
                }
                
                itemsJSON.append(["data": data.base64EncodedString()])
                group.leave()
            })
        }
        
        itemsJSON.append(["data": "blah"])
        group.notify(queue: DispatchQueue.global(qos: .default)) {
            completion(itemsJSON)
        }
    }
}
