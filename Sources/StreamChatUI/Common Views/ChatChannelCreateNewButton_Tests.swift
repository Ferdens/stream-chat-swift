//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatTestTools
@testable import StreamChatUI
import XCTest

class ChatChannelCreateNewButton_Tests: XCTestCase {
    let containerView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: 44, height: 44))
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let defaultSize = CGSize(width: 44, height: 44)
    
    func test_defaultAppearance() {
        let view = ChatChannelCreateNewButton().withoutAutoresizingMaskConstraints
        containerView.addSubview(view)
        AssertSnapshot(containerView, variants: [.small], size: defaultSize)
    }

    func test_customizationUsingAppearanceHook() {
        class TestView: ChatChannelCreateNewButton {}
        TestView.defaultAppearance {
            // Modify appearance
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.green.cgColor
            $0.backgroundColor = .black
            $0.tintColor = .lightGray
            
            // Modify layout
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalToConstant: 30),
                $0.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
        
        let view = TestView().withoutAutoresizingMaskConstraints
        containerView.addSubview(view)
        AssertSnapshot(containerView, variants: [.small], size: defaultSize)
    }

    func test_customizationUsingSubclassingHook() {
        class TestView: ChatChannelCreateNewButton {
            override func defaultAppearance() {
                super.defaultAppearance()
                layer.borderWidth = 1
                layer.borderColor = UIColor.green.cgColor
                backgroundColor = .black
                tintColor = .lightGray
                setImage(uiConfig.images.close, for: .normal)
            }
            
            override func setUpLayout() {
                super.setUpLayout()
                NSLayoutConstraint.activate([
                    widthAnchor.constraint(equalToConstant: 30),
                    heightAnchor.constraint(equalToConstant: 30)
                ])
            }
        }
        
        let view = TestView().withoutAutoresizingMaskConstraints
        containerView.addSubview(view)
        AssertSnapshot(containerView, variants: [.small], size: defaultSize)
    }
    
    func test_customizationUsingUIConfig() {
        var config = UIConfig()
        config.images.newChat = config.images.close

        let view = ChatChannelCreateNewButton().withoutAutoresizingMaskConstraints
        view.uiConfig = config
        containerView.addSubview(view)
        AssertSnapshot(containerView, variants: [.small], size: defaultSize)
    }
}
