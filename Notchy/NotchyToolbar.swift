//
//  NotchyToolbar.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/11/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import SuperLayout

@objc protocol NotchyToolbarDelegate {
    @objc func didToggleDeleteOriginalSwitch(sender: Any)
    @objc func notchifyButtonDidTouchUpInside(sender: Any)
    @objc func screenshotsButtonDidTouchUpInside(sender: Any)
    @objc func backButtonDidTouchUpInside(sender: Any)
}

final class NotchyToolbar: UIView {
    @objc private var delegate: NotchyToolbarDelegate!

    fileprivate var notchifyButton: RoundedButton!
    fileprivate var deleteOriginalLabel: UILabel!
    fileprivate var deleteOriginalSwitch: UISwitch!
    private var screenshotsButton: UIButton!
    private var backButton: UIButton!
    var stackView: UIStackView!

    init(delegate: NotchyToolbarDelegate) {
        super.init(frame: .zero)

        self.delegate = delegate

        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        let red = UIColor(0xE74C3B)
        screenshotsButton = UIButton()
        screenshotsButton.translatesAutoresizingMaskIntoConstraints = false

        let screenshotsButtonImage = UIImage(named: "Cards")?.image(withColor: red)
        screenshotsButton.setImage(screenshotsButtonImage, for: .normal)
        screenshotsButton.setImage(screenshotsButtonImage?.image(withAlpha: 0.5), for: .highlighted)
        screenshotsButton.addTarget(delegate, action: #selector(NotchyToolbarDelegate.screenshotsButtonDidTouchUpInside(sender:)), for: .touchUpInside)

        backButton = UIButton()
        backButton.isHidden = true
        backButton.translatesAutoresizingMaskIntoConstraints = false
        let backButtonImage = UIImage(named: "ArrowLeft")?.image(withColor: red)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.setImage(backButtonImage?.image(withAlpha: 0.5), for: .highlighted)
        backButton.addTarget(delegate, action: #selector(NotchyToolbarDelegate.backButtonDidTouchUpInside(sender:)), for: .touchUpInside)

        deleteOriginalLabel = UILabel()
        deleteOriginalLabel.text = "Delete Original?"

        deleteOriginalSwitch = UISwitch()
        deleteOriginalSwitch.isOn = true
        deleteOriginalSwitch.addTarget(delegate, action: #selector(NotchyToolbarDelegate.didToggleDeleteOriginalSwitch(sender:)), for: .valueChanged)

        let deleteOriginalStackView = UIStackView(arrangedSubviews: [deleteOriginalLabel, deleteOriginalSwitch])
        deleteOriginalStackView.translatesAutoresizingMaskIntoConstraints = false
        deleteOriginalStackView.axis = .horizontal
        deleteOriginalStackView.spacing = 15
        deleteOriginalStackView.isHidden = true

        notchifyButton = RoundedButton(color: red, textColor: .white, padding: 0)
        notchifyButton.translatesAutoresizingMaskIntoConstraints = false
        notchifyButton.setTitle("Notchify!", for: .normal)
        notchifyButton.addTarget(self, action: #selector(notchifyButtonDidTouchUpInside(_:)), for: .touchUpInside)

        stackView = UIStackView(arrangedSubviews: [notchifyButton, deleteOriginalStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10

        addSubview(backButton)
        addSubview(screenshotsButton)
        addSubview(stackView)

        let margin: CGFloat = 15

        screenshotsButton.centerYAnchor ~~ notchifyButton.centerYAnchor
        screenshotsButton.trailingAnchor ~~ trailingAnchor - margin

        backButton.centerYAnchor ~~ notchifyButton.centerYAnchor
        backButton.leadingAnchor ~~ leadingAnchor + margin

        stackView.topAnchor ~~ topAnchor + margin
        stackView.centerXAnchor ~~ centerXAnchor
    }

    func notchingComplete() {
        notchifyButton.isEnabled = true
        notchifyButton.setTitle("Notchify!", for: .normal)
    }

    @objc func notchifyButtonDidTouchUpInside(_ sender: Any) {
        notchifyButton.isEnabled = false
        notchifyButton.setTitle("Notching...", for: .normal)
        delegate.notchifyButtonDidTouchUpInside(sender: sender)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
