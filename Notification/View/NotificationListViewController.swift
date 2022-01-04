
//
//  InboxViewController.swift
//  Notification
//
//  Created by Fandy Gotama on 25/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Platform
import Domain
import L10n_swift

public protocol NotificationListViewControllerDelegate: class {
    func readStatusUpdated(totalUnread: Int)
    func notificationToBooking(controller: NotificationListViewController, id: Int)
    func needLogin()
}

public class NotificationListViewController: RxRestrictedViewController, NotificationAdapterDelegate, ListViewDelegate, EmptyListViewDelegate {
    private let _preference = UserPreference()

    public weak var delegate: NotificationListViewControllerDelegate?

    private lazy var _setReadViewModel: ViewModel<[Int], Status> = {
        let useCase = UseCaseProvider(
                service: SetNotificationStatusCloudService<Status>(),
                activityIndicator: activityIndicator)

        return ViewModel(useCase: useCase)
    }()

    private lazy var _deleteViewModel: ViewModel<Int, Status> = {

        let useCase = UseCaseProvider(
                service: DeleteNotificationCloudService<Status>(),
                activityIndicator: activityIndicator)

        return ViewModel<Int, Status>(useCase: useCase)
    }()

    private lazy var _dataSource: NotificationAdapter = {
        let dataSource = NotificationAdapter()

        dataSource.delegate = self

        return dataSource
    }()

    private lazy var _cache: NotificationSQLCache = {
        let delegate = UIApplication.shared.delegate as! AppDelegateType

        return NotificationSQLCache(dbQueue: delegate.dbQueue)
    }()

    private var _notifications: [Notification]?

    public lazy var notificationList: ListView<ListRequest, ListViewModel<ListRequest, List<Notification>>, NotificationAdapter, List<Notification>> = {

        let useCase = ListUseCaseProvider(
                service: NotificationCloudService<List<Notification>>(),
                cacheService: ListCacheService<ListRequest, List<Notification>, NotificationSQLCache>(cache: _cache),
                cache: _cache,
                activityIndicator: activityIndicator)

        let viewModel = ListViewModel(useCase: useCase, loadInitialCache: true)

        let layout = UICollectionViewFlowLayout()

        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 80)

        let v = ListView<ListRequest, ListViewModel<ListRequest, List<Notification>>, NotificationAdapter, List<Notification>>(
                with: NotificationCell.self,
                viewModel: viewModel,
                dataSource: _dataSource,
                layout: layout,
                allowPullToRefresh: true,
                emptyTitle: _preference.isAuthorized ? "no_notification_found".l10n() : "notification".l10n(),
                emptySubtitle: _preference.isAuthorized ? "no_notification_found_message".l10n() : "need_sign_in_notification_message".l10n(),
                emptyButton: _preference.isAuthorized ? nil : "login".l10n())

        v.emptyListDelegate = self
        v.delegate = self
        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.isSkeletonable = true

        view.addSubview(notificationList)

        NSLayoutConstraint.activate([
            notificationList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notificationList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            notificationList.topAnchor.constraint(equalTo: view.topAnchor),
            notificationList.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if _preference.isAuthorized {
            notificationList.collectionView.prepareSkeleton { [unowned self] done in
                loadData()
            }
        }

        binding()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !_preference.isAuthorized {
            _dataSource.list?.removeAll()
            notificationList.reloadData()
        }

        notificationList.emptyView.title = _preference.isAuthorized ? "no_notification_found".l10n() : "notification".l10n()
        notificationList.emptyView.subtitle = _preference.isAuthorized ? "no_notification_found_message".l10n() : "need_sign_in_notification_message".l10n()
        notificationList.emptyView.buttonTitle = _preference.isAuthorized ? nil : "login".l10n()

        notificationList.toggleEmptyView(show: !_preference.isAuthorized || _dataSource.list?.isEmpty == true)
    }

    override public func loadData() {
        view.showAnimatedSkeleton()

        notificationList.loadData(request: ListRequest(page: 1, forceReload: true))
    }

    public func dataLoaded<R, T>(list: [T], request: R, page: Int, isFromInitialCache: Bool) {
        guard let notifications = list as? [Notification] else { return }

        _notifications = notifications
    }

    public func unauthorized(result: Unauthorized) {
        // Do Nothing
    }

    // MARK: - EmptyListViewDelegate
    public func emptyButtonDidTap() {
        delegate?.needLogin()
    }

    // MARK: - NotificationAdapterDelegate
    public func notificationDeleted(notification: Notification) {
        _deleteViewModel.execute(request: notification.id)
    }

    public func notificationTapped(notification: Notification) {
        if let id = notification.bookingId {
            delegate?.notificationToBooking(controller: self, id: id)

            if notification.status == .unread {
                notification.status = .read

                _setReadViewModel.execute(request: [notification.id])

                delegate?.readStatusUpdated(totalUnread: _notifications?.filter { $0.status == .unread }.count ?? 0)

                let _ = _cache.update(model: notification)

                notificationList.collectionView.reloadData()
            }
        }
    }

    // MARK: - Private
    private func binding() {
        _setReadViewModel.result.drive().disposed(by: disposeBag)
        _deleteViewModel.result.drive().disposed(by: disposeBag)
    }
}
