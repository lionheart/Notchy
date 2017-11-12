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
}

final class NotchyToolbar: UIView {
    @objc private var delegate: NotchyToolbarDelegate!

    fileprivate var notchifyButton: RoundedButton!
    fileprivate var deleteOriginalLabel: UILabel!
    fileprivate var deleteOriginalSwitch: UISwitch!
    private var screenshotsButton: UIButton!
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
        notchifyButton.addTarget(self.delegate, action: #selector(NotchyToolbarDelegate.notchifyButtonDidTouchUpInside(sender:)), for: .touchUpInside)

        stackView = UIStackView(arrangedSubviews: [notchifyButton, deleteOriginalStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10

        addSubview(screenshotsButton)
        addSubview(stackView)

        let margin: CGFloat = 15

        screenshotsButton.centerYAnchor ~~ notchifyButton.centerYAnchor
        screenshotsButton.trailingAnchor ~~ trailingAnchor - margin

        stackView.topAnchor ~~ topAnchor + margin
        stackView.centerXAnchor ~~ centerXAnchor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
