//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

/// A view used to indicate the presence of a user.
public typealias ChatOnlineIndicatorView = _ChatOnlineIndicatorView<NoExtraData>

/// A view used to indicate the presence of a user.
open class _ChatOnlineIndicatorView<ExtraData: ExtraDataTypes>: View, UIConfigProvider {
    override public func defaultAppearance() {
        super.defaultAppearance()
        setupColors()
    }

    override open func setUpLayout() {
        super.setUpLayout()
        heightAnchor.pin(equalTo: widthAnchor).isActive = true
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        layer.frame = layer.frame.inset(by: .init(top: -1, left: -1, bottom: -1, right: -1))
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = (bounds.width / 5)
        layer.masksToBounds = true

        // Create a circle shape layer with true bounds.
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(ovalIn: bounds.inset(by: .init(top: -1, left: -1, bottom: -1, right: -1))).cgPath
        layer.mask = mask
    }

    // MARK: Private

    /// The sole existence of this function is to separate it and make sure we call only this
    /// inside `traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)`
    /// `cgColor` is just primitive CoreGraphics C class which doesn't have anything to do with
    /// dark/light mode, which makes this a bit more difficult to adopt...
    private func setupColors() {
        backgroundColor = uiConfig.colorPalette.alternativeActiveTint
        layer.borderColor = uiConfig.colorPalette.popoverBackground.cgColor
    }

    // MARK: TraitCollection

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupColors()
    }
}
