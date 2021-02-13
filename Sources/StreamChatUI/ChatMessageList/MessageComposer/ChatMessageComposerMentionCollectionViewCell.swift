//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

/// A View that is embed inside `UICollectionViewCell`  which shows information about user which we want to tag in suggestions
public typealias ChatMessageComposerMentionCellView = _ChatMessageComposerMentionCellView<NoExtraData>

/// A View that is embed inside `UICollectionViewCell`  which shows information about user which we want to tag in suggestions
open class _ChatMessageComposerMentionCellView<ExtraData: ExtraDataTypes>: View, UIConfigProvider {
    // MARK: Properties

    /// Content of the cell
    /// This is tuple which contains:
    /// - title: By default name of user
    /// - subtitle: By default tag of user
    /// - imageURL: URL of image for the user
    /// - isUserOnline: Indicates if user is online to set onlineIndicator visible
    open var content: (title: String, subtitle: String, imageURL: URL?, isUserOnline: Bool)? {
        didSet {
            updateContentIfNeeded()
        }
    }

    /// `_ChatChannelAvatarView` instance which holds photo of user for tagging.
    open private(set) lazy var avatarView = uiConfig
        .messageComposer
        .mentionAvatarView
        .init()
        .withoutAutoresizingMaskConstraints

    /// Title label which shows users whole name.
    open private(set) lazy var usernameLabel: UILabel = UILabel().withoutAutoresizingMaskConstraints
    /// Subtitle label which shows username tag etc. `@user`.
    open private(set) lazy var usernameTagLabel: UILabel = UILabel().withoutAutoresizingMaskConstraints
    /// ImageView which is located at the right part of the cell, showing @ symbol by default.
    open private(set) lazy var suggestionTypeImageView: UIImageView = UIImageView().withoutAutoresizingMaskConstraints
    /// StackView which holds username and userTag labels in vertical axis by default.
    open private(set) lazy var textStackView: UIStackView = UIStackView().withoutAutoresizingMaskConstraints

    // MARK: - Appearance

    override public func defaultAppearance() {
        backgroundColor = .clear
        usernameLabel.font = uiConfig.font.headlineBold

        usernameTagLabel.font = uiConfig.font.subheadlineBold
        usernameTagLabel.textColor = uiConfig.colorPalette.subtitleText

        usernameLabel.textColor = uiConfig.colorPalette.text

        suggestionTypeImageView.image = uiConfig.images.messageComposerCommandsMention
    }

    override open func setUpLayout() {
        addSubview(avatarView)
        addSubview(textStackView)
        addSubview(suggestionTypeImageView)

        setupLeftImageViewConstraints()
        setupStack()
        setupSuggestionTypeImageViewConstraints()
    }

    override open func updateContent() {
        usernameLabel.text = content?.title
        if let subtitle = content?.subtitle {
            usernameTagLabel.text = "@" + subtitle
        } else {
            usernameTagLabel.text = ""
        }

        avatarView.content = (content?.imageURL, content?.isUserOnline)
    }

    // MARK: Private

    private func setupLeftImageViewConstraints() {
        avatarView.leadingAnchor.pin(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        avatarView.topAnchor.pin(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        avatarView.bottomAnchor.pin(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        avatarView.widthAnchor.pin(equalToConstant: 40).isActive = true
        avatarView.heightAnchor.pin(equalTo: avatarView.widthAnchor).isActive = true
    }

    private func setupStack() {
        textStackView.axis = .vertical
        textStackView.distribution = .equalSpacing
        textStackView.alignment = .leading

        textStackView.addArrangedSubview(usernameLabel)
        textStackView.addArrangedSubview(usernameTagLabel)
        textStackView.centerYAnchor.pin(equalTo: avatarView.centerYAnchor).isActive = true
        textStackView.leadingAnchor.pin(equalToSystemSpacingAfter: avatarView.trailingAnchor, multiplier: 1).isActive = true

        textStackView.trailingAnchor.pin(equalTo: suggestionTypeImageView.leadingAnchor).isActive = true
    }

    private func setupSuggestionTypeImageViewConstraints() {
        suggestionTypeImageView.trailingAnchor.pin(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        suggestionTypeImageView.centerYAnchor.pin(equalTo: centerYAnchor).isActive = true
    }
}

/// `UICollectionView` subclass which embeds inside `ChatMessageComposerMentionCellView`
public typealias ChatMessageComposerMentionCollectionViewCell = _ChatMessageComposerMentionCollectionViewCell<NoExtraData>

/// `UICollectionView` subclass which embeds inside `ChatMessageComposerMentionCellView`
open class _ChatMessageComposerMentionCollectionViewCell<ExtraData: ExtraDataTypes>: CollectionViewCell, UIConfigProvider {
    // MARK: Properties

    /// Reuse identifier for the cell used in `collectionView(cellForItem:)`
    open class var reuseId: String { String(describing: self) }

    /// Instance of `ChatMessageComposerMentionCellView` which shows information about the mentioned user.
    public private(set) lazy var mentionView = uiConfig
        .messageComposer
        .suggestionsMentionCellView.init()
        .withoutAutoresizingMaskConstraints

    // MARK: - Lifecycle

    override open func setUpLayout() {
        super.setUpLayout()
        contentView.embed(mentionView, insets: contentView.directionalLayoutMargins)
    }

    // We need this method for `UICollectionViewCells` resize properly inside collectionView
    // and respect collectionView width. Without this method, the collectionViewCell content
    // autoresizes itself and ignores bounds of parent collectionView
    override open func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let preferredAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(
            width: layoutAttributes.frame.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        preferredAttributes.frame.size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        return preferredAttributes
    }
}
