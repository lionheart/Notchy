//
//  NotchyToolbar.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/11/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import SuperLayout
import LionheartExtensions

@objc protocol NotchyToolbarDelegate {
    @objc func didToggleDeleteOriginalSwitch(sender: Any)
    @objc func notchifyButtonDidTouchUpInside(sender: Any)
    @objc func screenshotsButtonDidTouchUpInside(sender: Any)
    @objc func backButtonDidTouchUpInside(sender: Any)
    @objc func addDeviceButtonDidTouchUpInside(_ sender: Any)
    @objc func removeWatermarkButtonDidTouchUpInside(_ sender: Any)
}

final class CheckmarkButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        imageView?.contentMode = .scaleAspectFit

        setImage(UIImage(named: "Circle"), for: .normal)
        setImage(UIImage(named: "CircleCheckmark")?.image(withAlpha: 0.5), for: .highlighted)
        setImage(UIImage(named: "CircleCheckmark")?.image(withAlpha: 0.5), for: .focused)
        setImage(UIImage(named: "CircleCheckmark"), for: .selected)

        let attributes: [NSAttributedStringKey: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.black
        ]
        let string = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(string, for: .normal)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)

        contentHorizontalAlignment = .left
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class CheckmarkView: UIStackView {
    private var button: UIButton!
    private var label: UILabel!

    init(title: String) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        spacing = 5

        button = UIButton()
        button.setImage(UIImage(named: "Circle"), for: .normal)
        let checkmark = UIImage(named: "CircleCheckmark")
        button.setImage(checkmark?.image(withColor: .blue), for: .highlighted)
        button.setImage(checkmark, for: .selected)

        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = title

        addArrangedSubview(button)
        addArrangedSubview(label)

        button.heightAnchor ~~ button.widthAnchor
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
        button.addTarget(target, action: action, for: controlEvents)
    }
}

final class NotchyToolbar: UIView {
    @objc private var delegate: NotchyToolbarDelegate!

    fileprivate var notchifyButton: RoundedButton!
    fileprivate var deleteOriginalLabel: UILabel!
    fileprivate var deleteOriginalSwitch: UISwitch!
    private var screenshotsButton: UIButton!
    private var backButton: UIButton!
    var stackView: UIStackView!

    var addDeviceCheckmarkView: CheckmarkButton!
    var deleteCheckmarkView: CheckmarkButton!
    var removeWatermarkCheckmarkView: CheckmarkButton!

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

        addDeviceCheckmarkView = CheckmarkButton(title: "Add Device")
        addDeviceCheckmarkView.addTarget(self, action: #selector(addDeviceButtonDidTouchUpInside(_:)), for: .touchUpInside)

        deleteCheckmarkView = CheckmarkButton(title: "Delete Original")
        deleteCheckmarkView.addTarget(self, action: #selector(deleteButtonDidTouchUpInside(_:)), for: .touchUpInside)

        removeWatermarkCheckmarkView = CheckmarkButton(title: "Remove Watermark")
        removeWatermarkCheckmarkView.addTarget(self, action: #selector(removeWatermarkButtonDidTouchUpInside(_:)), for: .touchUpInside)

        notchifyButton = RoundedButton(color: red, textColor: .white, padding: 0)
        notchifyButton.translatesAutoresizingMaskIntoConstraints = false
        notchifyButton.setTitle("Notchify!", for: .normal)
        notchifyButton.addTarget(self, action: #selector(notchifyButtonDidTouchUpInside(_:)), for: .touchUpInside)

        stackView = UIStackView(arrangedSubviews: [addDeviceCheckmarkView, deleteCheckmarkView, removeWatermarkCheckmarkView, notchifyButton, deleteOriginalStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10

        addSubview(backButton)
        addSubview(screenshotsButton)
        addSubview(stackView)

        stackView.setCustomSpacing(2, after: addDeviceCheckmarkView)
        stackView.setCustomSpacing(2, after: deleteCheckmarkView)

        let margin: CGFloat = 15

        deleteCheckmarkView.heightAnchor ~~ 30
        addDeviceCheckmarkView.heightAnchor ~~ 30
        removeWatermarkCheckmarkView.heightAnchor ~~ 30

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

    @objc func deleteButtonDidTouchUpInside(_ sender: Any) {
        deleteCheckmarkView.isSelected = !deleteCheckmarkView.isSelected
    }

    @objc func removeWatermarkButtonDidTouchUpInside(_ sender: Any) {
        removeWatermarkCheckmarkView.isSelected = !removeWatermarkCheckmarkView.isSelected
    }

    @objc func addDeviceButtonDidTouchUpInside(_ sender: Any) {
        addDeviceCheckmarkView.isSelected = !addDeviceCheckmarkView.isSelected
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
