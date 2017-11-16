//
//  ExtraStuffView.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/15/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import SuperLayout

final class ExtraStuffItemView: UIStackView {
    init(imageName: String, text: String) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        spacing = 10

        let imageView = UIImageView(image: UIImage(named: imageName))

        let label = UILabel()
        label.text = text
        label.font = NotchyTheme.systemFont(ofSize: 15, weight: .medium)

        addArrangedSubview(imageView)
        addArrangedSubview(label)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ExtraStuffView: UIView {
    init() {
        super.init(frame: .zero)

        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 10
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5

        let topLabel = UILabel()
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.text = "Extra Stuff!"
        topLabel.font = NotchyTheme.systemFont(ofSize: 24, weight: .medium)

        let item1 = ExtraStuffItemView(imageName: "IAP-AddiPhone", text: "Add iPhone X")
        let item2 = ExtraStuffItemView(imageName: "IAP-RemoveWatermark", text: "Remove Watermark")
        let item3 = ExtraStuffItemView(imageName: "IAP-IconOptions", text: "8 Icon Options")

        let optionsStackView = UIStackView(arrangedSubviews: [item1, item2, item3])
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.axis = .vertical
        optionsStackView.spacing = 10
        optionsStackView.alignment = .leading

        let getStuffButton = PlainButton()
        getStuffButton.setTitle("Get Extra Stuff - $1.99", for: .normal, size: 14)

        let restorePurchasesButton = UIButton(type: .system)
        restorePurchasesButton.translatesAutoresizingMaskIntoConstraints = false
        restorePurchasesButton.titleLabel?.font = NotchyTheme.systemFont(ofSize: 12, weight: .medium)
        restorePurchasesButton.setTitle("Restore Purchase", for: .normal)

        let stackView = UIStackView(arrangedSubviews: [topLabel, optionsStackView, getStuffButton, restorePurchasesButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.setCustomSpacing(30, after: topLabel)
        stackView.setCustomSpacing(30, after: optionsStackView)

        addSubview(stackView)

        let margin: CGFloat = 15
        stackView.leadingAnchor ~~ leadingAnchor + margin
        stackView.trailingAnchor ~~ trailingAnchor - margin
        stackView.topAnchor ~~ topAnchor + margin
        stackView.bottomAnchor ~~ bottomAnchor - margin
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
