//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatTestTools
@testable import StreamChatUI
import XCTest

class ChatMessageComposerMentionCellView_Tests: XCTestCase {
    /// Default reference width for the cell on current tested device
    private static var defaultCellWidth = UIScreen.main.bounds.width - 16

    override func setUp() {
        super.setUp()
    }

    func test_emptyAppearance() {
        let view = ChatMessageComposerMentionCellView().withoutAutoresizingMaskConstraints
        view.widthAnchor.constraint(equalToConstant: Self.defaultCellWidth).isActive = true

        AssertSnapshot(view, variants: [.small], record: true)
    }

    func test_defaultAppearance_withUserOnline() {
        let view = ChatMessageComposerMentionCellView().withoutAutoresizingMaskConstraints
        view.widthAnchor.constraint(equalToConstant: Self.defaultCellWidth).isActive = true
        view.content = ("Mr Vader", "darkforce37", TestImages.vader.url, true)

        AssertSnapshot(view, variants: [.small], record: true)
    }

    func test_defaultAppearance_withUserOffline() {
        let view = ChatMessageComposerMentionCellView().withoutAutoresizingMaskConstraints
        view.widthAnchor.constraint(equalToConstant: Self.defaultCellWidth).isActive = true
        view.content = ("Mr Vader", "darkforce37", TestImages.vader.url, false)

        AssertSnapshot(view, variants: [.small], record: true)
    }

//
//    func test_defaultAppearance_withNonDMChannel() {
//        // TODO: https://stream-io.atlassian.net/browse/CIS-652
//    }
//
//    func test_appearanceCustomization_usingUIConfig() {
//        class RectIndicator: UIView {
//            override func didMoveToSuperview() {
//                super.didMoveToSuperview()
//                backgroundColor = .systemPink
//                widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
//            }
//        }
//
//        var config = UIConfig()
//        config.channelList.channelListItemSubviews.onlineIndicator = RectIndicator.self
//        config.colorPalette.alternativeActiveTint = .brown
//        config.colorPalette.lightBorder = .cyan
//
//        let view = ChatChannelAvatarView().withoutAutoresizingMaskConstraints
//        view.addSizeConstraints()
//        view.uiConfig = config
//        view.content = (channel, currentUserId)
//        AssertSnapshot(view, variants: [.small])
//    }
//
//    func test_appearanceCustomization_usingAppearanceHook() {
//        class TestView: ChatChannelAvatarView {}
//        TestView.defaultAppearance {
//            // Modify appearance
//            $0.onlineIndicatorView.backgroundColor = .red
//            $0.backgroundColor = .yellow
//
//            // Modify layout
//            NSLayoutConstraint.activate([
//                $0.onlineIndicatorView.leftAnchor.constraint(equalTo: $0.leftAnchor),
//                $0.onlineIndicatorView.bottomAnchor.constraint(equalTo: $0.bottomAnchor),
//                $0.onlineIndicatorView.widthAnchor.constraint(equalToConstant: 20)
//            ])
//        }
//
//        let view = TestView().withoutAutoresizingMaskConstraints
//        view.addSizeConstraints()
//        view.content = (channel, currentUserId)
//        AssertSnapshot(view, variants: [.small])
//    }
//
//    func test_appearanceCustomization_usingSubclassing() {
//        class TestView: ChatChannelAvatarView {
//            override func setUpAppearance() {
//                onlineIndicatorView.backgroundColor = .red
//                backgroundColor = .yellow
//            }
//
//            override func setUpLayout() {
//                super.setUpLayout()
//                NSLayoutConstraint.activate([
//                    onlineIndicatorView.leftAnchor.constraint(equalTo: leftAnchor),
//                    onlineIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
//                    onlineIndicatorView.widthAnchor.constraint(equalToConstant: 20)
//                ])
//            }
//        }
//
//        let view = TestView().withoutAutoresizingMaskConstraints
//        view.addSizeConstraints()
//        view.content = (channel, currentUserId)
//        AssertSnapshot(view, variants: [.small])
//    }
}
