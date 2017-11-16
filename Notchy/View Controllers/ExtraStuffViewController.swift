//
//  ExtraStuffViewController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/16/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import SuperLayout

final class ExtraStuffViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let extraStuffView = ExtraStuffView()

        view.addSubview(extraStuffView)

        extraStuffView.leadingAnchor ~~ view.leadingAnchor
        extraStuffView.trailingAnchor ~~ view.trailingAnchor
        extraStuffView.topAnchor ~~ view.topAnchor
        extraStuffView.bottomAnchor ~~ view.bottomAnchor
    }
}

