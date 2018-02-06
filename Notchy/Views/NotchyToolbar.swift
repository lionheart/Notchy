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
    @objc func saveButtonDidTouchUpInside(_ sender: Any)
    @objc func copyButtonDidTouchUpInside(_ sender: Any)
    @objc func shareButtonDidTouchUpInside(_ sender: Any)
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
            .font: NotchyTheme.systemFont(ofSize: 15),
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
        label.font = NotchyTheme.systemFont(ofSize: 14)
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

    private var saveButton: PlainButton!
    private var copyButton: ShortPlainButton!
    private var shareButton: UIButton!
    var stackView: UIStackView!

    var addDeviceCheckmarkView: CheckmarkButton!
    var deleteCheckmarkView: CheckmarkButton!
    var removeWatermarkCheckmarkView: CheckmarkButton!
    
    enum ToolbarType {
        case regular
        case short
    }

    init(delegate: NotchyToolbarDelegate, type: ToolbarType) {
        super.init(frame: .zero)

        self.delegate = delegate

        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        var shortButtonStackView: UIStackView?
        let arrangedSubviews: [UIView]
        let anchorView: UIView
        switch type {
        case .regular:
            saveButton = PlainButton()
            saveButton.addTarget(delegate, action: #selector(NotchyToolbarDelegate.saveButtonDidTouchUpInside(_:)), for: .touchUpInside)
            saveButton.setTitle("Save to Photos", for: .normal)
            
            copyButton = ShortPlainButton()
            copyButton.setTitle("Copy", for: .normal)
            copyButton.addTarget(delegate, action: #selector(NotchyToolbarDelegate.copyButtonDidTouchUpInside(_:)), for: .touchUpInside)
            
            shareButton = ShortPlainButton()
            shareButton.setTitle("Share", for: .normal)
            shareButton.addTarget(delegate, action: #selector(NotchyToolbarDelegate.shareButtonDidTouchUpInside(_:)), for: .touchUpInside)
            
            shortButtonStackView = UIStackView(arrangedSubviews: [copyButton, shareButton])
            shortButtonStackView?.axis = .horizontal
            shortButtonStackView?.spacing = 0
            shortButtonStackView?.distribution = .equalSpacing
            shortButtonStackView?.alignment = .bottom
            
            arrangedSubviews = [saveButton, shortButtonStackView!]
            
            anchorView = saveButton
            
        case .short:
            shareButton = PlainButton()
            shareButton.setTitle("Share", for: .normal)
            
            let shareIcon = UIImage(named: "Share")?.image(withColor: .white)
            shareButton.setImage(shareIcon, for: .normal)
            shareButton.reversesTitleShadowWhenHighlighted = false
            shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
            shareButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            shareButton.addTarget(delegate, action: #selector(NotchyToolbarDelegate.shareButtonDidTouchUpInside(_:)), for: .touchUpInside)
            
            arrangedSubviews = [shareButton]
            
            anchorView = shareButton
        }

        addDeviceCheckmarkView = CheckmarkButton(title: "Add Device")
        addDeviceCheckmarkView.addTarget(self, action: #selector(addDeviceButtonDidTouchUpInside(_:)), for: .touchUpInside)

        removeWatermarkCheckmarkView = CheckmarkButton(title: "Remove Watermark")
        removeWatermarkCheckmarkView.addTarget(self, action: #selector(removeWatermarkButtonDidTouchUpInside(_:)), for: .touchUpInside)

        stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        
        if !arrangedSubviews.contains(shareButton) {
            stackView.setCustomSpacing(UIStackView.spacingUseSystem, after: saveButton)
        }

        addSubview(stackView)

        if let stackView = shortButtonStackView {
            stackView.widthAnchor ~~ 125
        }

        anchorView.leadingAnchor.constraintEqualToSystemSpacingAfter(stackView.leadingAnchor, multiplier: 2).isActive = true
        stackView.trailingAnchor.constraintEqualToSystemSpacingAfter(anchorView.trailingAnchor, multiplier: 2).isActive = true
        stackView.topAnchor.constraintEqualToSystemSpacingBelow(topAnchor, multiplier: 2).isActive = true

        stackView.widthAnchor ~~ widthAnchor
        stackView.centerXAnchor ~~ centerXAnchor
    }

    func notchingComplete() {
        // MARK: TODO
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
