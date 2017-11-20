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
    @objc func thanksButtonDidTouchUpInside(_ sender: Any)
}

enum ExtraStuffInfo {
    case addPhone
    case removeWatermark
    case icons

    var imageName: String {
        switch self {
        case .addPhone: return "iPhoneXIcon"
        case .removeWatermark: return "WatermarkIcon"
        case .icons: return "IconsIcon"
        }
    }

    var title: String {
        switch self {
        case .addPhone: return "Add iPhone X"
        case .removeWatermark: return "Remove Watermark"
        case .icons: return "8 Icon Options"
        }
    }

    var imageWidth: CGFloat {
        switch self {
        case .addPhone: return 15
        case .removeWatermark: return 30
        case .icons: return 30
        }
    }
}

final class ExtraStuffItemView: UIStackView {
    init(info: ExtraStuffInfo) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal

        let imageView = UIImageView(image: UIImage(named: info.imageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        let imageContainer = UIView()
        imageContainer.addSubview(imageView)

        imageView.widthAnchor ~~ info.imageWidth
        imageView.leadingAnchor ~~ imageContainer.leadingAnchor
        imageView.trailingAnchor ≤≤ imageContainer.trailingAnchor
        imageView.topAnchor ~~ imageContainer.topAnchor
        imageView.bottomAnchor ~~ imageContainer.bottomAnchor

        let label = UILabel()
        label.text = info.title
        label.font = NotchyTheme.systemFont(ofSize: 15, weight: .medium)

        addArrangedSubview(imageContainer)
        addArrangedSubview(label)

        imageContainer.widthAnchor ~~ 40
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ExtraStuffView: UIView {
    weak var delegate: ExtraStuffViewDelegate!

    private var getStuffButton: PlainButton!
    private var thanksButton: PlainButton!
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

        let item1 = ExtraStuffItemView(info: .addPhone)
        let item2 = ExtraStuffItemView(info: .removeWatermark)
        let item3 = ExtraStuffItemView(info: .icons)

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

        thanksButton = PlainButton()
        thanksButton.isHidden = true
        thanksButton.setTitle("Thanks!", for: .normal, size: 14)
        thanksButton.addTarget(self, action: #selector(thanksButtonDidTouchUpInside(_:)), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [topLabel, optionsStackView, getStuffButton, restorePurchasesButton, thanksButton])
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

    enum TransactionStatus {
        case success
        case failure
    }

    @objc func thanksButtonDidTouchUpInside(_ sender: Any) {
        delegate.thanksButtonDidTouchUpInside(sender)
    }

    func transactionCompleted(status: TransactionStatus) {
        switch status {
        case .success:
            break

        case .failure:
            activity?.removeFromSuperview()
            getStuffButton.isEnabled = true
            restorePurchasesButton.isEnabled = true
            getStuffButton.isSelected = false
        }
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
