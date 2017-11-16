//
//  NotchyAlertAnimation.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/16/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import Presentr

final class NotchyAlertAnimation: PresentrAnimation {
    init(duration: TimeInterval) {
        super.init(options: .normal(duration: duration))
    }

    override public func beforeAnimation(using transitionContext: PresentrTransitionContext) {
        transitionContext.animatingView?.alpha = transitionContext.isPresenting ? 0.0 : 1.0
    }

    override public func performAnimation(using transitionContext: PresentrTransitionContext) {
        transitionContext.animatingView?.alpha = transitionContext.isPresenting ? 1.0 : 0.0
    }

    override public func afterAnimation(using transitionContext: PresentrTransitionContext) {
        transitionContext.animatingView?.alpha = 1.0
    }
}
