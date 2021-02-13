// swift-tools-version:5.3
// When used via SPM the minimum Swift version is 5.3 because we need support for resources

import Foundation
import PackageDescription

let package = Package(
    name: "StreamChat",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "StreamChat",
            targets: ["StreamChat"]),
        .library(
            name: "StreamChatUI",
            targets: ["StreamChatUI"]
        )
    ],
    dependencies: [
        // StreamChat
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0"),
        
        // StreamChatUI
        .package(url: "https://github.com/kean/Nuke.git", from: "9.0.0"),
        .package(url: "https://github.com/kirualex/SwiftyGif.git", from: "5.3.0")
    ],
    targets: [
        .target(
            name: "StreamChat",
            dependencies: ["Starscream"],
            exclude: ["README.md", "Info.plist"] + streamChatSourcesExcluded,
            resources: [.copy("Database/StreamChatModel.xcdatamodeld")]
        ),
        .target(
            name: "StreamChatUI",
            dependencies: ["StreamChat", "Nuke", "SwiftyGif"],
            exclude: ["README.md", "Info.plist"] + streamChatUIFilesExcluded,
            resources: [.process("Sources/StreamChatUI/Resources")]
        )
    ]
)

// ** ⚠️ GENERATED, do not edit directly below this point **

var streamChatSourcesExcluded: [String] { [
    "Database/DataStore_Tests.swift",
    "Database/DatabaseSession_Tests.swift",
    "Database/DTOs/UserDTO_Tests.swift",
    "Database/DTOs/ChannelDTO_Tests.swift",
    "Database/DTOs/CurrentUserDTO_Tests.swift",
    "Database/DTOs/MemberModelDTO_Tests.swift",
    "Database/DTOs/MessageReactionDTO_Tests.swift",
    "Database/DTOs/AttachmentDTO_Tests.swift",
    "Database/DTOs/MessageDTO_Tests.swift",
    "Database/DTOs/ChannelMemberListQueryDTO_Tests.swift",
    "Database/DTOs/DeviceDTO_Tests.swift",
    "Database/DatabaseContainer_Mock.swift",
    "Database/DatabaseContainer_Tests.swift",
    "Config/TokenProvider_Tests.swift",
    "WebSocketClient/WebSocketClient_Mock.swift",
    "WebSocketClient/EventMiddlewares/ChannelReadUpdaterMiddleware_Tests.swift",
    "WebSocketClient/EventMiddlewares/MessageReactionsMiddleware_Tests.swift",
    "WebSocketClient/EventMiddlewares/TypingStartCleanupMiddleware_Tests.swift",
    "WebSocketClient/EventMiddlewares/EventMiddleware_Mock.swift",
    "WebSocketClient/EventMiddlewares/ChannelMemberTypingStateUpdaterMiddleware_Tests.swift",
    "WebSocketClient/EventMiddlewares/EventMiddleware_Tests.swift",
    "WebSocketClient/EventMiddlewares/EventDataProcessorMiddleware_Tests.swift",
    "WebSocketClient/ConnectionStatus_Tests.swift",
    "WebSocketClient/WebSocketClient_Tests.swift",
    "WebSocketClient/WebSocketReconnectionStrategy_Tests.swift",
    "WebSocketClient/Events/UserEvents_Tests.swift",
    "WebSocketClient/Events/TypingEvent_Tests.swift",
    "WebSocketClient/Events/EventPayload_Tests.swift",
    "WebSocketClient/Events/MessageEvents_Tests.swift",
    "WebSocketClient/Events/NotificationEvents_Tests.swift",
    "WebSocketClient/Events/ReactionEvents_Tests.swift",
    "WebSocketClient/Events/ChannelEvents_Tests.swift",
    "WebSocketClient/Events/MemberEvents_Tests.swift",
    "WebSocketClient/Engine/WebSocketEngine_Mock.swift",
    "WebSocketClient/WebSocketPingController_Tests.swift",
    "APIClient/HTTPHeader_Tests.swift",
    "APIClient/Endpoints/GuestEndpoints_Tests.swift",
    "APIClient/Endpoints/Payloads/AttachmentPayload_Tests.swift",
    "APIClient/Endpoints/Payloads/DevicePayloads_Tests.swift",
    "APIClient/Endpoints/Payloads/CurrentUserPayloads_Tests.swift",
    "APIClient/Endpoints/Payloads/FlagMessagePayload_Tests.swift",
    "APIClient/Endpoints/Payloads/ChannelListPayload_Tests.swift",
    "APIClient/Endpoints/Payloads/FlagUserPayload_Tests.swift",
    "APIClient/Endpoints/Payloads/MessagePayloads_Tests.swift",
    "APIClient/Endpoints/Payloads/MissingEventsPayload_Tests.swift",
    "APIClient/Endpoints/Payloads/FileUploadPayload_Tests.swift",
    "APIClient/Endpoints/Payloads/UserPayloads_Tests.swift",
    "APIClient/Endpoints/Payloads/UserListPayload_Tests.swift",
    "APIClient/Endpoints/Payloads/MessageReactionPayload_Tests.swift",
    "APIClient/Endpoints/Payloads/GuestUserTokenPayload_Tests.swift",
    "APIClient/Endpoints/Payloads/RawJSON_Tests.swift",
    "APIClient/Endpoints/Payloads/ChannelEditDetailPayload_Tests.swift",
    "APIClient/Endpoints/Payloads/ChannelMemberListPayload_Tests.swift",
    "APIClient/Endpoints/Payloads/MemberPayload_Tests.swift",
    "APIClient/Endpoints/AttachmentEndpoints_Tests.swift",
    "APIClient/Endpoints/SyncEndpoint_Tests.swift",
    "APIClient/Endpoints/MessageEndpoints_Tests.swift",
    "APIClient/Endpoints/DeviceEndpoints_Tests.swift",
    "APIClient/Endpoints/Requests/GuestUserTokenRequestPayload_Tests.swift",
    "APIClient/Endpoints/Requests/MissingEventsRequestBody_Tests.swift",
    "APIClient/Endpoints/Requests/ChannelMemberBanRequestPayload_Tests.swift",
    "APIClient/Endpoints/Requests/AttachmentActionRequestBody_Tests.swift",
    "APIClient/Endpoints/Requests/MessageReactionRequestPayload_Tests.swift",
    "APIClient/Endpoints/WebSocketConnectEndpoint_Tests.swift",
    "APIClient/Endpoints/MemberEndpoints_Tests.swift",
    "APIClient/Endpoints/ChannelEndpoints_Tests.swift",
    "APIClient/Endpoints/ModerationEndpoints_Tests.swift",
    "APIClient/Endpoints/UserEndpoints_Tests.swift",
    "APIClient/APIClient_Tests.swift",
    "APIClient/APIClient_Mock.swift",
    "APIClient/RequestDecoder_Tests.swift",
    "APIClient/RequestEncoder_Tests.swift",
    "ChatClient_Tests.swift",
    "Utils/Database/NSManagedObject_Tests.swift",
    "Utils/Internet Connection/InternetConnection_Tests.swift",
    "Utils/MulticastDelegate_Tests.swift",
    "Utils/Atomic_Tests.swift",
    "Utils/AssignIfDifferent_Tests.swift",
    "Utils/LazyCachedMapCollection_Tests.swift",
    "Utils/Dictionary_Tests.swift",
    "Utils/Cached_Tests.swift",
    "Models/MessageReactionType_Tests.swift",
    "Models/ChannelId_Tests.swift",
    "Models/Attachments/AttachmentTypes_Tests.swift",
    "Models/Attachments/AttachmentId_Tests.swift",
    "Workers/Background/NewChannelQueryUpdater_Tests.swift",
    "Workers/Background/AttachmentUploader_Tests.swift",
    "Workers/Background/NewUserQueryUpdater_Tests.swift",
    "Workers/Background/MissingEventsPublisher_Tests.swift",
    "Workers/Background/ChannelWatchStateUpdater_Tests.swift",
    "Workers/Background/MessageSender_Tests.swift",
    "Workers/Background/MessageEditor_Tests.swift",
    "Workers/ChannelMemberUpdater_Tests.swift",
    "Workers/EventObservers/TypingEventObserver_Tests.swift",
    "Workers/EventObservers/MemberEventObserver_Tests.swift",
    "Workers/EventObservers/EventObserver_Tests.swift",
    "Workers/UserUpdater_Mock.swift",
    "Workers/UserUpdater_Tests.swift",
    "Workers/CurrentUserUpdater_Tests.swift",
    "Workers/ChannelMemberUpdater_Mock.swift",
    "Workers/CurrentUserUpdater_Mock.swift",
    "Workers/ChatClientUpdater_Mock.swift",
    "Workers/MessageUpdater_Tests.swift",
    "Workers/UserListUpdater_Tests.swift",
    "Workers/ChannelUpdater_Tests.swift",
    "Workers/MessageUpdater_Mock.swift",
    "Workers/ChannelMemberListUpdater_Tests.swift",
    "Workers/EventSender_Tests.swift",
    "Workers/ChannelMemberListUpdater_Mock.swift",
    "Workers/EventSender_Mock.swift",
    "Workers/UserListUpdater_Mock.swift",
    "Workers/ChannelListUpdater_Mock.swift",
    "Workers/ChannelListUpdater_Tests.swift",
    "Workers/ChannelUpdater_Mock.swift",
    "Workers/EventNotificationCenter_Tests.swift",
    "Workers/ChatClientUpdater_Tests.swift",
    "Query/ChannelMemberListQuery_Tests.swift",
    "Query/UserListQuery_Tests.swift",
    "Query/ChannelListQuery_Tests.swift",
    "Query/Pagination_Tests.swift",
    "Query/Sorting/Sorting_Tests.swift",
    "Query/Filter_Tests.swift",
    "Query/ChannelQuery_Tests.swift",
    "Controllers/ChannelController/ChannelController+SwiftUI_Tests.swift",
    "Controllers/ChannelController/ChannelController_Tests.swift",
    "Controllers/ChannelController/ChannelController+Combine_Tests.swift",
    "Controllers/ListDatabaseObserver_Tests.swift",
    "Controllers/DataController_Tests.swift",
    "Controllers/SearchControllers/UserSearchController_Tests.swift",
    "Controllers/MemberController/MemberController+SwiftUI_Tests.swift",
    "Controllers/MemberController/MemberController_Tests.swift",
    "Controllers/MemberController/MemberController+Combine_Tests.swift",
    "Controllers/MessageController/MessageController+SwiftUI_Tests.swift",
    "Controllers/MessageController/MessageController_Tests.swift",
    "Controllers/MessageController/MessageController+Combine_Tests.swift",
    "Controllers/ListDatabaseObserver_Mock.swift",
    "Controllers/ChannelListController/ChannelListController+SwiftUI_Tests.swift",
    "Controllers/ChannelListController/ChannelListController_Tests.swift",
    "Controllers/ChannelListController/ChannelListController+Combine_Tests.swift",
    "Controllers/CurrentUserController/CurrentUserController+Combine_Tests.swift",
    "Controllers/CurrentUserController/CurrentUserController+SwiftUI_Tests.swift",
    "Controllers/CurrentUserController/CurrentUserController_Tests.swift",
    "Controllers/EntityDatabaseObserver_Mock.swift",
    "Controllers/EntityDatabaseObserver_Tests.swift",
    "Controllers/UserListController/UserListController+Combine_Tests.swift",
    "Controllers/UserListController/UserListController_Tests.swift",
    "Controllers/UserListController/UserListController+SwiftUI_Tests.swift",
    "Controllers/UserController/UserController+Combine_Tests.swift",
    "Controllers/UserController/UserController+SwiftUI_Tests.swift",
    "Controllers/UserController/UserController_Tests.swift",
    "Controllers/ConnectionController/ConnectionController+SwiftUI_Tests.swift",
    "Controllers/ConnectionController/ConnectionController+Combine_Tests.swift",
    "Controllers/ConnectionController/ConnectionController_Tests.swift",
    "Controllers/MemberListController/MemberListController+Combine_Tests.swift",
    "Controllers/MemberListController/MemberListController_Tests.swift",
    "Controllers/MemberListController/MemberListController_Mock.swift",
    "Controllers/MemberListController/MemberListController+SwiftUI_Tests.swift",
    "ChatClient_Mock.swift"
] }

var streamChatUIFilesExcluded: [String] { [
    "ChatMessageList/MessageComposer/ChatMessageComposerMentionCellView_Tests.swift",
    "ChatMessageList/MessageComposer/__Snapshots__/ChatMessageComposerMentionCellView_Tests/test_emptyAppearance.small.png",
    "Utils/UIConfigProvider_Tests.swift",
    "ChatChannelList/ChatChannelAvatarView_Tests.swift",
    "ChatChannelList/ChatChannelListVC_Tests.swift",
    "ChatChannelList/__Snapshots__/ChatChannelListVC_Tests/test_chatChannelList_isPopulated.large.png",
    "ChatChannelList/__Snapshots__/ChatChannelListVC_Tests/test_chatChannelList_isPopulated.extraExtraExtraLarge.png",
    "ChatChannelList/__Snapshots__/ChatChannelListVC_Tests/test_chatChannelList_isPopulated.small.png",
    "ChatChannelList/__Snapshots__/ChatChannelAvatarView_Tests/test_appearanceCustomization_usingAppearanceHook.small.png",
    "ChatChannelList/__Snapshots__/ChatChannelAvatarView_Tests/test_appearanceCustomization_usingUIConfig.small.png",
    "ChatChannelList/__Snapshots__/ChatChannelAvatarView_Tests/test_defaultAppearance_withDirectMessageChannel.small.png",
    "ChatChannelList/__Snapshots__/ChatChannelAvatarView_Tests/test_appearanceCustomization_usingSubclassing.small.png",
    "ChatChannelList/__Snapshots__/ChatChannelAvatarView_Tests/test_defaultAppearance_withDirectMessageChannel.small-with-online-indicator.png",
    "ChatChannelList/__Snapshots__/ChatChannelAvatarView_Tests/test_emptyAppearance.small.png",
    "Common Views/CurrentChatUserAvatarView_Tests.swift",
    "Common Views/__Snapshots__/CurrentChatUserAvatarView_Tests/test_customizationUsingSubclassingHook.small.png",
    "Common Views/__Snapshots__/CurrentChatUserAvatarView_Tests/test_defaultAppearance.small.png",
    "Common Views/__Snapshots__/CurrentChatUserAvatarView_Tests/test_customizationUsingSubclassingHook.small-empty.png",
    "Common Views/__Snapshots__/CurrentChatUserAvatarView_Tests/test_customizationUsingAppearanceHook.small.png",
    "Common Views/__Snapshots__/CurrentChatUserAvatarView_Tests/test_emptyAppearance.small.png",
    "Common Views/__Snapshots__/CurrentChatUserAvatarView_Tests/test_customizationUsingAppearanceHook.small-empty.png"
] }
