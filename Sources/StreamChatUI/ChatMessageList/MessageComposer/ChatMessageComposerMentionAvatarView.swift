//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

/// A view that shows a user avatar including an indicator of the user presence (online/offline).
public typealias ChatMessageComposerMentionAvatarView = _ChatChannelAvatarView<NoExtraData>

/// A view that shows a user avatar including an indicator of the user presence (online/offline).
open class _ChatMessageComposerMentionAvatarView<ExtraData: ExtraDataTypes>: ChatAvatarView, UIConfigProvider {
    /// A view indicating whether the user this view represents is online.
    open private(set) lazy var onlineIndicatorView: UIView = uiConfig
        .channelList
        .channelListItemSubviews
        .onlineIndicator.init()
        .withoutAutoresizingMaskConstraints

    /// The data this view component shows.
    open var content: (imageURL: URL?, isOnlineIndicatorVisible: Bool?) {
        didSet { updateContentIfNeeded() }
    }

    override public func defaultAppearance() {
        super.defaultAppearance()
        onlineIndicatorView.isHidden = true
    }

    override open func setUpLayout() {
        super.setUpLayout()
        // Add online indicator view
        addSubview(onlineIndicatorView)
        onlineIndicatorView.pin(anchors: [.top, .right], to: self)
        onlineIndicatorView.widthAnchor
            .pin(equalTo: widthAnchor, multiplier: 0.3)
            .isActive = true
    }

    override open func updateContent() {
        // If user has image, show it. Otherwise use first placeholder.
        if let url = content.imageURL {
            imageView.loadImage(from: url)
        } else {
            imageView.image = uiConfig.images.userAvatarPlaceholder1
        }
        onlineIndicatorView.isVisible = content.isOnlineIndicatorVisible ?? false
    }
}
