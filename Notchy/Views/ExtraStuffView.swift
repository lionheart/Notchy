//
//  ExtraStuffView.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/15/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import SuperLayout

@objc protocol ExtraStuffViewDelegate: class {
    @objc func getStuffButtonDidTouchUpInside(_ sender: Any)
    @objc func restoreButtonDidTouchUpInside(_ sender: Any)
}

final class ExtraStuffItemView: UIStackView {
    init(imageName: String, text: String) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        spacing = 10

        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = text
        label.font = NotchyTheme.systemFont(ofSize: 15, weight: .medium)

        addArrangedSubview(imageView)
        addArrangedSubview(label)

        imageView.widthAnchor ~~ 30
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ExtraStuffView: UIView {
    weak var delegate: ExtraStuffViewDelegate!

    private var getStuffButton: PlainButton!
    private var restorePurchasesButton: UIButton!

    private var activity: UIActivityIndicatorView?

    init(delegate: ExtraStuffViewDelegate) {
        super.init(frame: .zero)

        self.delegate = delegate

        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 10
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5

        let topLabel = UILabel()
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.text = "EXTRA STUFF"
        topLabel.font = NotchyTheme.systemFont(ofSize: 24, weight: .medium)

        let item1 = ExtraStuffItemView(imageName: "iPhoneXIcon", text: "Add iPhone X")
        let item2 = ExtraStuffItemView(imageName: "WatermarkIcon", text: "Remove Watermark")
        let item3 = ExtraStuffItemView(imageName: "IconsIcon", text: "8 Icon Options")

        let optionsStackView = UIStackView(arrangedSubviews: [item1, item2, item3])
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.axis = .vertical
        optionsStackView.spacing = 10
        optionsStackView.alignment = .leading

        getStuffButton = PlainButton()
        getStuffButton.addTarget(self, action: #selector(getStuffButtonDidTouchUpInside(_:)), for: .touchUpInside)
        getStuffButton.setTitle("Add Extra Stuff - $1.99", for: .normal, size: 14)
        getStuffButton.setTitle(nil, for: .selected, size: 14)

        restorePurchasesButton = UIButton(type: .system)
        restorePurchasesButton.addTarget(self, action: #selector(restoreButtonDidTouchUpInside(_:)), for: .touchUpInside)
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

    func transactionCompleted() {
        activity?.removeFromSuperview()
        getStuffButton.isEnabled = true
        restorePurchasesButton.isEnabled = true
        getStuffButton.isSelected = false
    }

    private func transactionStarted() {
        getStuffButton.isSelected = true
        getStuffButton.isEnabled = false
        restorePurchasesButton.isEnabled = false

        activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
        guard let activity = activity else {
            return
        }

        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.startAnimating()

        getStuffButton.addSubview(activity)

        activity.centerXAnchor ~~ getStuffButton.centerXAnchor
        activity.centerYAnchor ~~ getStuffButton.centerYAnchor
    }

    @objc func getStuffButtonDidTouchUpInside(_ sender: Any) {
        transactionStarted()
        delegate.getStuffButtonDidTouchUpInside(sender)
    }

    @objc func restoreButtonDidTouchUpInside(_ sender: Any) {
        transactionStarted()
        delegate.restoreButtonDidTouchUpInside(sender)
    }
}
