//
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CoreData
import Foundation

extension Client {
    /// Creates a new `ChannelController` for the channel with the provided id and options.
    ///
    /// - Parameter channelId: The id of the channel this controller represents.
    /// - Parameter options: Query options (See `QueryOptions`)
    /// - Returns: A new instance of `ChannelController`.
    ///
    public func channelController(for cid: ChannelId, options: QueryOptions = .all) -> ChannelControllerGeneric<ExtraData> {
        .init(channelQuery: .init(cid: cid, options: options), client: self)
    }
    
    /// Creates a new `ChannelController` for the channel with the provided channel query.
    ///
    /// - Parameter channelQuery: The ChannelQuery this controller represents
    /// - Returns: A new instance of `ChannelController`.
    ///
    public func channelController(for channelQuery: ChannelQuery<ExtraData>) -> ChannelControllerGeneric<ExtraData> {
        .init(channelQuery: channelQuery, client: self)
    }

    /// Creates a new `ChannelController` that will create new channel.
    ///
    /// - Parameters:
    ///   - cid: The `ChannelId` for the new channel.
    ///   - team: Team for new channel.
    ///   - members: IDs for the new channel members.
    ///   - invites: IDs for the new channel invitees.
    ///   - extraData: Extra data for the new channel.
    /// - Returns: A new instance of `ChannelController`.
    public func channelController(
        createChannelWithId cid: ChannelId,
        team: String? = nil,
        members: Set<UserId> = [],
        invites: Set<UserId> = [],
        extraData: ExtraData.Channel
    ) -> ChannelControllerGeneric<ExtraData> {
        let payload = ChannelEditDetailPayload<ExtraData>(cid: cid,
                                                          team: team,
                                                          members: members,
                                                          invites: invites,
                                                          extraData: extraData)
        return .init(channelQuery: .init(channelPayload: payload), client: self, isChannelAlreadyCreated: false)
    }

    /// Creates a new `ChannelController` that will create new channel with members without id. It's great for direct message
    /// channels.
    /// - Parameters:
    ///   - members: Members for the new channel. Must not be empty.
    ///   - team: Team for the new channel.
    ///   - extraData: Extra data for the new channel.
    /// - Returns: A new instance of `ChannelController`.
    public func channelController(
        createDirectMessageChannelWith members: Set<UserId>,
        team: String? = nil,
        extraData: ExtraData.Channel
    ) throws -> ChannelControllerGeneric<ExtraData> {
        guard !members.isEmpty else { throw ClientError.ChannelEmptyMembers() }
        let payload = ChannelEditDetailPayload<ExtraData>(cid: .init(type: .messaging, id: ""),
                                                          team: team,
                                                          members: members,
                                                          invites: [],
                                                          extraData: extraData)
        return .init(channelQuery: .init(channelPayload: payload), client: self, isChannelAlreadyCreated: false)
    }
}

/// A convenience typealias for `ChannelControllerGeneric` with `DefaultDataTypes`
public typealias ChannelController = ChannelControllerGeneric<DefaultDataTypes>

/// `ChannelController` allows observing and mutating the controlled channel.
///
///  ... you can do this and that
///
public class ChannelControllerGeneric<ExtraData: ExtraDataTypes>: Controller, DelegateCallable {
    /// The ChannelQuery this controller observes.
    @Atomic public private(set) var channelQuery: ChannelQuery<ExtraData>

    /// The identifier of a channel this controller observes.
    private var channelId: ChannelId { channelQuery.cid }
    
    /// The `ChatClient` instance this controller belongs to.
    public let client: Client<ExtraData>
    
    /// The channel matching the channelId. To observe updates to the channel,
    /// set your class as a delegate of this controller and call `startUpdating`.
    public var channel: ChannelModel<ExtraData>? {
        guard state != .inactive else {
            log.warning("Accessing `channel` before calling `startUpdating()` always results in `nil`.")
            return nil
        }
        
        return channelObserver.item
    }
    
    /// The channel matching the channelId. To observe updates to the channel,
    /// set your class as a delegate of this controller and call `startUpdating`.
    public var messages: [MessageModel<ExtraData>] {
        guard state != .inactive else {
            log.warning("Accessing `messages` before calling `startUpdating()` always results in an empty array.")
            return []
        }
        
        return messagesObserver.items
    }
    
    /// The worker used to fetch the remote data and communicate with servers.
    private lazy var worker: ChannelUpdater<ExtraData> = self.environment.channelUpdaterBuilder(client.databaseContainer,
                                                                                                client.webSocketClient,
                                                                                                client.apiClient)
    
    /// A type-erased delegate.
    private(set) var anyDelegate: AnyChannelControllerDelegate<ExtraData>? {
        didSet {
            // Set `Controller` `ControllerStateDelegate` delegate
            stateDelegate = anyDelegate
        }
    }

    @Cached private var channelObserver: EntityDatabaseObserver<ChannelModel<ExtraData>, ChannelDTO>
    @Cached private var messagesObserver: ListDatabaseObserver<MessageModel<ExtraData>, MessageDTO>
    
    private var eventObservers: [EventObserver] = []
    private let environment: Environment

    // Flag indicating whether channel is created on backend. We need this flag to restrict channel modification requests
    // before channel is created on backend.
    private var isChannelAlreadyCreated: Bool
    // This callback is called after channel is created on backend but before channel is saved to DB. When channel is created
    // we receive backend generated cid and setting up current `ChannelController` to observe this channel DB changes.
    // Completion will be called if DB fetch will fail after setting new `ChannelQuery`.
    private func channelCreated(completion: ((_ error: Error?) -> Void)?) -> ((ChannelId) -> Void) {
        return { [weak self] cid in
            guard let self = self else { return }
            self.isChannelAlreadyCreated = true
            self.set(channelQuery: ChannelQuery(cid: cid, channelQuery: self.channelQuery), completion: completion)
        }
    }

    /// Creates a new `ChannelController`
    /// - Parameters:
    ///   - channelQuery: channel query for observing changes
    ///   - client: The `Client` this controller belongs to.
    ///   - environment: Envrionment for this controller.
    ///   - isChannelAlreadyCreated: Flag indicating whether channel is created on backend.
    init(
        channelQuery: ChannelQuery<ExtraData>,
        client: Client<ExtraData>,
        environment: Environment = .init(),
        isChannelAlreadyCreated: Bool = true
    ) {
        self.channelQuery = channelQuery
        self.client = client
        self.environment = environment
        self.isChannelAlreadyCreated = isChannelAlreadyCreated
        super.init()

        setChannelObserver()
        setMessagesObserver()
    }

    private func setChannelObserver() {
        _channelObserver.computeValue = { [unowned self] in
            let observer = EntityDatabaseObserver(context: self.client.databaseContainer.viewContext,
                                                  fetchRequest: ChannelDTO.fetchRequest(for: self.channelQuery.cid),
                                                  itemCreator: ChannelModel<ExtraData>.create)
            observer.onChange = { change in
                self.delegateCallback { $0?.channelController(self, didUpdateChannel: change) }
            }

            return observer
        }
    }

    private func setMessagesObserver() {
        _messagesObserver.computeValue = { [unowned self] in
            let observer = ListDatabaseObserver(context: self.client.databaseContainer.viewContext,
                                                fetchRequest: MessageDTO.messagesFetchRequest(for: self.channelQuery.cid),
                                                itemCreator: MessageModel<ExtraData>.init)
            observer.onChange = { changes in
                self.delegateCallback {
                    $0?.channelController(self, didUpdateMessages: changes)
                }
            }

            return observer
        }
    }
    
    /// Starts updating the results.
    ///
    /// 1. **Synchronously** loads the data for the referenced objects from the local cache. These data are immediately available in
    /// the `channel` property of the controller once this method returns. Any further changes to the data are communicated
    /// using `delegate`.
    ///
    /// 2. It also **asynchronously** fetches the latest version of the data from the servers. Once the remote fetch is completed,
    /// the completion block is called. If the updated data differ from the locally cached ones, the controller uses the `delegate`
    /// methods to inform about the changes.
    ///
    /// - Parameter completion: Called when the controller has finished fetching remote data.
    ///                         If the data fetching fails, the `error` variable contains more details about the problem.
    public func startUpdating(_ completion: ((_ error: Error?) -> Void)? = nil) {
        eventObservers.removeAll()
        startDatabaseObservers(completion)

        // Update observing state
        state = .localDataFetched

        let channelCreatedCallback = isChannelAlreadyCreated ? nil : channelCreated(completion: completion)
        worker.update(channelQuery: channelQuery,
                      channelCreatedCallback: channelCreatedCallback) { [weak self] error in
            guard let self = self else { return }
            self.state = error == nil ? .remoteDataFetched : .remoteDataFetchFailed(ClientError(with: error))
            self.callback { completion?(error) }
        }

        setupEventObservers()
    }

    // After setting new channelQuery we need to reset current DB observers to observe new channel.
    // Completion will be called if observers will fail to fetch data for the new channel.
    private func set(channelQuery: ChannelQuery<ExtraData>, completion: ((_ error: Error?) -> Void)?) {
        guard self.channelQuery.cid != channelQuery.cid else { return }
        self.channelQuery = channelQuery
        startDatabaseObservers(completion)
    }

    private func startDatabaseObservers(_ completion: ((_ error: Error?) -> Void)? = nil) {
        _channelObserver.reset()
        _messagesObserver.reset()

        do {
            try channelObserver.startObserving()
            try messagesObserver.startObserving()
        } catch {
            log.error("Failed to perform fetch request with error: \(error). This is an internal error.")
            callback { completion?(ClientError.FetchFailed()) }
            return
        }
    }

    private func setupEventObservers() {
        let center = client.webSocketClient.notificationCenter
        eventObservers = [
            MemberEventObserver(notificationCenter: center, cid: channelId) { [unowned self] event in
                self.delegateCallback {
                    $0?.channelController(self, didReceiveMemberEvent: event)
                }
            }
        ]
    }
    
    /// Sets the provided object as a delegate of this controller.
    ///
    /// - Note: If you don't use custom extra data types, you can set the delegate directly using `controller.delegate = self`.
    /// Due to the current limits of Swift and the way it handles protocols with associated types, it's required to use this
    /// method to set the delegate, if you're using custom extra data types.
    ///
    /// - Parameter delegate: The object used as a delegate. It's referenced weakly, so you need to keep the object
    /// alive if you want keep receiving updates.
    public func setDelegate<Delegate: ChannelControllerDelegateGeneric>(_ delegate: Delegate)
        where Delegate.ExtraData == ExtraData {
        anyDelegate = AnyChannelControllerDelegate(delegate)
    }
}

// MARK: - Channel actions

public extension ChannelControllerGeneric {
    /// Updated channel with new data
    /// - Parameters:
    ///   - team: New team.
    ///   - members: New members.
    ///   - invites: New invites.
    ///   - extraData: New `ExtraData`.
    ///   - completion: The completion. Will be called on a **callbackQueue** when the network request is finished.
    ///                 If request fails, the completion will be called with an error.
    func updateChannel(
        team: String?,
        members: Set<UserId> = [],
        invites: Set<UserId> = [],
        extraData: ExtraData.Channel,
        completion: ((Error?) -> Void)? = nil
    ) {
        guard isChannelAlreadyCreated else {
            channelModificationFailed(completion)
            return
        }

        let payload: ChannelEditDetailPayload<ExtraData> = .init(cid: channelId, team: team, members: members, invites: invites,
                                                                 extraData: extraData)
        worker.updateChannel(channelPayload: payload) { [weak self] error in
            self?.callback {
                completion?(error)
            }
        }
    }

    /// Mutes the channel this controller manages.
    /// - Parameter completion: The completion. Will be called on a **callbackQueue** when the network request is finished.
    ///                         If request fails, the completion will be called with an error.
    func muteChannel(completion: ((Error?) -> Void)? = nil) {
        guard isChannelAlreadyCreated else {
            channelModificationFailed(completion)
            return
        }
        worker.muteChannel(cid: channelId, mute: true) { [weak self] error in
            self?.callback {
                completion?(error)
            }
        }
    }

    /// Unmutes the channel this controller manages.
    /// - Parameters:
    ///   - completion: The completion. Will be called on a **callbackQueue** when the network request is finished.
    ///                 If request fails, the completion will be called with an error.
    func unmuteChannel(completion: ((Error?) -> Void)? = nil) {
        guard isChannelAlreadyCreated else {
            channelModificationFailed(completion)
            return
        }
        worker.muteChannel(cid: channelId, mute: false) { [weak self] error in
            self?.callback {
                completion?(error)
            }
        }
    }

    /// Delete the channel this controller manages.
    /// - Parameters:
    ///   - completion: The completion. Will be called on a **callbackQueue** when the network request is finished.
    ///                 If request fails, the completion will be called with an error.
    func deleteChannel(completion: ((Error?) -> Void)? = nil) {
        guard isChannelAlreadyCreated else {
            channelModificationFailed(completion)
            return
        }
        worker.deleteChannel(cid: channelId) { [weak self] error in
            self?.callback {
                completion?(error)
            }
        }
    }

    /// Hide the channel this controller manages from queryChannels for the user until a message is added.
    /// - Parameters:
    ///   - clearHistory: Flag to remove channel history (**false** by default)
    ///   - completion: The completion. Will be called on a **callbackQueue** when the network request is finished.
    ///                 If request fails, the completion will be called with an error.
    func hideChannel(clearHistory: Bool = false, completion: ((Error?) -> Void)? = nil) {
        guard isChannelAlreadyCreated else {
            channelModificationFailed(completion)
            return
        }
        worker.hideChannel(cid: channelId, userId: client.currentUserId, clearHistory: clearHistory) { [weak self] error in
            self?.callback {
                completion?(error)
            }
        }
    }

    /// Removes hidden status for the channel this controller manages.
    /// - Parameter completion: The completion. Will be called on a **callbackQueue** when the network request is finished.
    ///                         If request fails, the completion will be called with an error.
    func showChannel(completion: ((Error?) -> Void)? = nil) {
        guard isChannelAlreadyCreated else {
            channelModificationFailed(completion)
            return
        }
        worker.showChannel(cid: channelId, userId: client.currentUserId) { [weak self] error in
            self?.callback {
                completion?(error)
            }
        }
    }

    // It's impossible to perform any channel modification before it's creation on backend.
    // So before any modification attempt we need to check if channel is already created and call this function if not.
    private func channelModificationFailed(_ completion: ((Error?) -> Void)?) {
        let error = ClientError.ChannelNotCreatedYet()
        log.error(error.localizedDescription)
        callback {
            completion?(error)
        }
    }
}

extension ChannelControllerGeneric {
    struct Environment {
        var channelUpdaterBuilder: (
            _ database: DatabaseContainer,
            _ webSocketClient: WebSocketClient,
            _ apiClient: APIClient
        ) -> ChannelUpdater<ExtraData> = ChannelUpdater.init
    }
}

public extension ChannelControllerGeneric where ExtraData == DefaultDataTypes {
    /// Set the delegate of `ChannelController` to observe the changes in the system.
    ///
    /// - Note: The delegate can be set directly only if you're **not** using custom extra data types. Due to the current
    /// limits of Swift and the way it handles protocols with associated types, it's required to use `setDelegate` method
    /// instead to set the delegate, if you're using custom extra data types.
    var delegate: ChannelControllerDelegate? {
        set { anyDelegate = AnyChannelControllerDelegate(newValue) }
        get { anyDelegate?.wrappedDelegate as? ChannelControllerDelegate }
    }
}

// MARK: - Delegates

/// `ChannelController` uses this protocol to communicate changes to its delegate.
///
/// This protocol can be used only when no custom extra data are specified. If you're using custom extra data types,
/// please use `ChannelControllerDelegateGeneric` instead.
public protocol ChannelControllerDelegate: ControllerStateDelegate {
    /// The controller observed a change in the `Channel` entity.
    func channelController(
        _ channelController: ChannelController,
        didUpdateChannel channel: EntityChange<Channel>
    )
    
    /// The controller observed changes in the `Messages` of the observed channel.
    func channelController(
        _ channelController: ChannelController,
        didUpdateMessages changes: [ListChange<Message>]
    )

    /// The controller received a `MemberEvent` related to the channel it observes.
    func channelController(_ channelController: ChannelController, didReceiveMemberEvent: MemberEvent)
}

public extension ChannelControllerDelegate {
    func channelController(
        _ channelController: ChannelController,
        didUpdateChannel channel: EntityChange<Channel>
    ) {}
    
    func channelController(
        _ channelController: ChannelController,
        didUpdateMessages changes: [ListChange<Message>]
    ) {}

    func channelController(_ channelController: ChannelController, didReceiveMemberEvent: MemberEvent) {}
}

// MARK: Generic Delegates

/// `ChannelController` uses this protocol to communicate changes to its delegate.
///
/// If you're **not** using custom extra data types, you can use a convenience version of this protocol
/// named `ChannelControllerDelegate`, which hides the generic types, and make the usage easier.
public protocol ChannelControllerDelegateGeneric: ControllerStateDelegate {
    associatedtype ExtraData: ExtraDataTypes
    
    /// The controller observed a change in the `Channel` entity.
    func channelController(
        _ channelController: ChannelControllerGeneric<ExtraData>,
        didUpdateChannel channel: EntityChange<ChannelModel<ExtraData>>
    )
    
    /// The controller observed changes in the `Messages` of the observed channel.
    func channelController(
        _ channelController: ChannelControllerGeneric<ExtraData>,
        didUpdateMessages changes: [ListChange<MessageModel<ExtraData>>]
    )

    /// The controller received a `MemberEvent` related to the channel it observes.
    func channelController(_ channelController: ChannelControllerGeneric<ExtraData>, didReceiveMemberEvent: MemberEvent)
}

public extension ChannelControllerDelegateGeneric {
    func channelController(
        _ channelController: ChannelControllerGeneric<ExtraData>,
        didUpdateChannel channel: EntityChange<ChannelModel<ExtraData>>
    ) {}
    
    func channelController(
        _ channelController: ChannelController,
        didUpdateMessages changes: [ListChange<MessageModel<ExtraData>>]
    ) {}

    func channelController(_ channelController: ChannelControllerGeneric<ExtraData>, didReceiveMemberEvent: MemberEvent) {}
}

// MARK: Type erased Delegate

class AnyChannelControllerDelegate<ExtraData: ExtraDataTypes>: ChannelListControllerDelegateGeneric {
    private var _controllerdidUpdateMessages: (
        ChannelControllerGeneric<ExtraData>,
        [ListChange<MessageModel<ExtraData>>]
    ) -> Void
    
    private var _controllerDidUpdateChannel: (
        ChannelControllerGeneric<ExtraData>,
        EntityChange<ChannelModel<ExtraData>>
    ) -> Void

    private var _controllerDidChangeState: (Controller, Controller.State) -> Void
    
    private var _controllerDidReceiveMemberEvent: (
        ChannelControllerGeneric<ExtraData>,
        MemberEvent
    ) -> Void

    weak var wrappedDelegate: AnyObject?
    
    init(
        wrappedDelegate: AnyObject?,
        controllerDidChangeState: @escaping (Controller, Controller.State) -> Void,
        controllerDidUpdateChannel: @escaping (
            ChannelControllerGeneric<ExtraData>,
            EntityChange<ChannelModel<ExtraData>>
        ) -> Void,
        controllerdidUpdateMessages: @escaping (
            ChannelControllerGeneric<ExtraData>,
            [ListChange<MessageModel<ExtraData>>]
        ) -> Void,
        controllerDidReceiveMemberEvent: @escaping (
            ChannelControllerGeneric<ExtraData>,
            MemberEvent
        ) -> Void
    ) {
        self.wrappedDelegate = wrappedDelegate
        _controllerDidChangeState = controllerDidChangeState
        _controllerDidUpdateChannel = controllerDidUpdateChannel
        _controllerdidUpdateMessages = controllerdidUpdateMessages
        _controllerDidReceiveMemberEvent = controllerDidReceiveMemberEvent
    }

    func controller(_ controller: Controller, didChangeState state: Controller.State) {
        _controllerDidChangeState(controller, state)
    }
    
    func channelController(
        _ controller: ChannelControllerGeneric<ExtraData>,
        didUpdateChannel channel: EntityChange<ChannelModel<ExtraData>>
    ) {
        _controllerDidUpdateChannel(controller, channel)
    }
    
    func channelController(
        _ controller: ChannelControllerGeneric<ExtraData>,
        didUpdateMessages changes: [ListChange<MessageModel<ExtraData>>]
    ) {
        _controllerdidUpdateMessages(controller, changes)
    }

    func channelController(
        _ controller: ChannelControllerGeneric<ExtraData>,
        didReceiveMemberEvent event: MemberEvent
    ) {
        _controllerDidReceiveMemberEvent(controller, event)
    }
}

extension AnyChannelControllerDelegate {
    convenience init<Delegate: ChannelControllerDelegateGeneric>(_ delegate: Delegate) where Delegate.ExtraData == ExtraData {
        self.init(wrappedDelegate: delegate,
                  controllerDidChangeState: { [weak delegate] in delegate?.controller($0, didChangeState: $1) },
                  controllerDidUpdateChannel: { [weak delegate] in delegate?.channelController($0, didUpdateChannel: $1) },
                  controllerdidUpdateMessages: { [weak delegate] in delegate?.channelController($0, didUpdateMessages: $1) },
                  controllerDidReceiveMemberEvent: { [weak delegate] in
                      delegate?.channelController($0, didReceiveMemberEvent: $1)
                  })
    }
}

extension AnyChannelControllerDelegate where ExtraData == DefaultDataTypes {
    convenience init(_ delegate: ChannelControllerDelegate?) {
        self.init(wrappedDelegate: delegate,
                  controllerDidChangeState: { [weak delegate] in delegate?.controller($0, didChangeState: $1) },
                  controllerDidUpdateChannel: { [weak delegate] in delegate?.channelController($0, didUpdateChannel: $1) },
                  controllerdidUpdateMessages: { [weak delegate] in delegate?.channelController($0, didUpdateMessages: $1) },
                  controllerDidReceiveMemberEvent: { [weak delegate] in
                      delegate?.channelController($0, didReceiveMemberEvent: $1)
                  })
    }
}

extension ClientError {
    class ChannelNotCreatedYet: ClientError {
        override public var localizedDescription: String {
            // swiftlint:disable:next line_length
            "You can't modify the channel because the channel hasn't been created yet. Call `startUpdating()` to create the channel and wait for the completion block to finish. Alternatively, you can observe the `state` changes of the controller and wait for the `remoteDataFetched` state."
        }
    }

    class ChannelEmptyMembers: ClientError {
        override public var localizedDescription: String {
            "You can't create direct messaging channel with empty members."
        }
    }
}