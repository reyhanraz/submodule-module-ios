//
//  BookingDetailViewController.swift
//  Booking
//
//  Created by Fandy Gotama on 31/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Platform
import Domain
import MessageUI
import SkeletonView
import CoreLocation
import MapKit
import Toast_Swift
import Payment
import FittedSheets

public protocol BookingDetailViewControllerDelegate: AnyObject {
    func statusUpdated(booking: Booking)
    func paymentUpdated(booking: Booking)
    func editBooking(booking: Booking)
    func loadBidderFailed()
    func viewArtisan(artisan: Artisan)
    func showCalendar(date: Date)
    func showRating(controller: BookingDetailViewController, booking: Booking, artisan: Artisan)
}

public class BookingDetailViewController: RxRestrictedViewController, MFMessageComposeViewControllerDelegate, BookingUserViewDelegate, BookingVenueViewDelegate, BidRequestDialogViewDelegate, CheckoutViewControllerDelegate, PostComplaintViewControllerDelegate {
    private let _id: Int
    private let _userKind: User.Kind
    private let _cache: BookingSQLCache?
    private let _avatarSize: CGFloat = 40
    
    private let _preference = ArtisanPreference()
    
    private var _booking: Booking?
    private var _paymentSummary: PaymentSummary?
    private var _acceptedArtisan: Artisan?
    private var _bidderList: [Artisan]?
    
    private var _stackViewTopConstraint: NSLayoutConstraint!
    
    public weak var delegate: BookingDetailViewControllerDelegate?
    
    let lblBookingID: UILabel = {
        let v = UILabel()
        
        v.text = "                       "
        v.font = regularBody2
        v.textColor = .black
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isSkeletonable = true
        
        return v
    }()
    
    let lblDate: UILabel = {
        let v = UILabel()
        
        v.font = regularBody2
        v.textColor = UIColor.black
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isSkeletonable = true
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return v
    }()
    
    let bookingSeparator: SeparatorView = {
        let v = SeparatorView(color: UIColor.BeautyBell.gray300)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let statusSeparator: SeparatorView = {
        let v = SeparatorView(color: UIColor.BeautyBell.gray300)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let venueSeparator: SeparatorView = {
        let v = SeparatorView(color: UIColor.BeautyBell.gray300)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblStatusTitle: UILabel = {
        let v = UILabel()
        
        v.text = "status".l10n()
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblStatus: UILabel = {
        let v = UILabel()
        
        v.text = "               "
        v.isSkeletonable = true
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let serviceSummaryView: BookingServiceSummaryView = {
        let v = BookingServiceSummaryView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let reviewView: BookingReviewView = {
        let v = BookingReviewView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()
    
    let complaintView: BookingComplaintView = {
        let v = BookingComplaintView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()
    
    let bidderStackView: UIStackView = {
        let v = UIStackView()
        
        v.axis = .vertical
        v.spacing = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblRefundInfo: UILabel = {
        let v = UILabel()
        
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray600
        v.numberOfLines = 0
        v.textAlignment = .center
        v.isUserInteractionEnabled = true
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        
        return v
    }()
    
    let lblBookingStatus: UILabel = {
        let v = UILabel()
        
        v.textColor = UIColor.BeautyBell.gray600
        v.font = regularBody2
        v.numberOfLines = 1
        v.textAlignment = .right
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true

        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var venueView: BookingVenueView = {
        let v = BookingVenueView(userKind: _userKind)
        
        v.delegate = self
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var profileView: BookingUserView = {
        let v = BookingUserView(kind: _userKind)
        
        v.delegate = self
        v.translatesAutoresizingMaskIntoConstraints = false
        v.accept = true
        
        return v
    }()
    
    lazy var btnUpdateStatus: CustomButton = {
        let v = CustomButton()
        v.isHidden = true
        v.displayType = .primary
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(updateStatus(_:)), for: .touchUpInside)
        
        return v
    }()
    
    lazy var bidRequestDialogView: BidRequestDialogView = {
        let v = BidRequestDialogView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        
        return v
    }()
    
    lazy var btnReview: CustomButton = {
        let v = CustomButton()
        
        v.displayType = .primary
        v.text = "review".l10n()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(reviewTapped), for: .touchUpInside)
        v.isSkeletonable = true
        v.isHidden = true
        
        return v
    }()
    
    lazy var btnComplaint: CustomButton = {
        let v = CustomButton()
        
        v.displayType = .secondary
        v.text = "complain".l10n()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(complaintTapped), for: .touchUpInside)
        v.isSkeletonable = true
        v.isHidden = true
        
        return v
    }()
    
    lazy var btnPayment: CustomButton = {
        let v = CustomButton()
        
        v.displayType = .primary
        v.text = "complete_payment".l10n()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(goToPayment), for: .touchUpInside)
        v.isHidden = true
        
        return v
    }()
    
    lazy var btnRefund: CustomButton = {
        let v = CustomButton()
        
        v.displayType = .primary
        v.text = "refund".l10n()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(refund), for: .touchUpInside)
        v.isHidden = true
        
        return v
    }()
    
    lazy var btnCancel: CustomButton = {
        let v = CustomButton()
        
        v.displayType = .secondary
        v.text = "cancel".l10n()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
        v.isSkeletonable = true
        v.isHidden = true
        
        return v
    }()
    
    lazy var buttonStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [btnReview, btnComplaint, btnCancel, btnPayment, lblRefundInfo, btnRefund, btnUpdateStatus])
        
        v.axis = .vertical
        v.spacing = 15
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var paymentSummaryView: BookingPaymentSummaryView = {
        let v = BookingPaymentSummaryView()
        
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var usersAndServicesStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [serviceSummaryView, paymentSummaryView, profileView, reviewView, complaintView])
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isSkeletonable = true
        
        v.axis = .vertical
        v.spacing = 15
        
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        
        v.addSubview(lblBookingID)
        v.addSubview(lblDate)
        v.addSubview(bookingSeparator)
        v.addSubview(lblStatusTitle)
        v.addSubview(lblStatus)
        v.addSubview(lblBookingStatus)
        v.addSubview(bidderStackView)
        v.addSubview(statusSeparator)
        v.addSubview(usersAndServicesStackView)
        v.addSubview(venueView)
        v.addSubview(venueSeparator)
        v.addSubview(buttonStackView)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private lazy var _getPaymentURLViewModel: ViewModel<PaymentRequest, PaymentSummaryDetail> = {
        let service = GetPaymentURLCloudService<PaymentSummaryDetail>()
        
        let useCase = UseCaseProvider(
            service: service,
            activityIndicator: activityIndicator)
        
        return ViewModel(loadingText: "payment_loading".l10n(), useCase: useCase)
    }()
    
    private lazy var _updateViewModel: ViewModel<(bookingListRequest: BookingListRequest, checkAvailabilityRequest: CheckAvailabilityRequest?), BookingDetail> = {
        
        let service = UpdateBookingStatusCloudService<BookingDetail>()
        let availabilityService = CheckAvailabilityCloudService<Availability>()
        
        let useCase = UpdateBookingStatusUseCaseProvider(
            service: service,
            availabilityService: availabilityService,
            cache: _cache,
            activityIndicator: activityIndicator)
        
        return ViewModel(loadingText: "updating".l10n(), useCase: useCase)
    }()
    
    private lazy var _bidderViewModel: ViewModel<Int, RequestBidders> = {
        let service = RequestBidderCloudService<RequestBidders>()
        let useCase = UseCaseProvider(service: service, activityIndicator: activityIndicator)
        
        return ViewModel(useCase: useCase)
    }()
    
    private lazy var _viewModel: ViewModel<BookingListRequest, BookingDetail> = {
        
        let service = BookingCloudService<BookingDetail>()
        let cacheService: BookingCacheService<BookingListRequest, BookingSQLCache>?
        
        if let cache = _cache {
            cacheService = BookingCacheService(cache: cache)
        } else {
            cacheService = nil
        }
        
        let useCase = GetDetailUseCaseProvider(
            service: service,
            cacheService: cacheService,
            cache: _cache,
            forceReload: true,
            activityIndicator: activityIndicator)
        
        return ViewModel(useCase: useCase)
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    public init(id: Int, userKind: User.Kind, cache: BookingSQLCache?) {
        _id = id
        _userKind = userKind
        _cache = cache
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(artisanTapped))
        let refundInfoTapGesture = UITapGestureRecognizer(target: self, action: #selector(copyRefundCode))
        
        lblRefundInfo.addGestureRecognizer(refundInfoTapGesture)
        profileView.addGestureRecognizer(tapGesture)
        
        view.backgroundColor = .white
        view.isSkeletonable = true
        
        scrollView.isSkeletonable = true
        
        view.addSubview(scrollView)
        
        _stackViewTopConstraint = bidderStackView.topAnchor.constraint(equalTo: lblBookingStatus.bottomAnchor)
        _stackViewTopConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            lblBookingID.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lblBookingID.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            lblBookingID.trailingAnchor.constraint(lessThanOrEqualTo: lblDate.leadingAnchor, constant: -10),
            
            lblDate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lblDate.centerYAnchor.constraint(equalTo: lblBookingID.centerYAnchor),
            
            bookingSeparator.leadingAnchor.constraint(equalTo: lblBookingID.leadingAnchor),
            bookingSeparator.trailingAnchor.constraint(equalTo: lblDate.trailingAnchor),
            bookingSeparator.topAnchor.constraint(equalTo: lblBookingID.bottomAnchor, constant: 10),
            
            lblStatusTitle.leadingAnchor.constraint(equalTo: bookingSeparator.leadingAnchor),
            lblStatusTitle.trailingAnchor.constraint(equalTo: bookingSeparator.trailingAnchor),
            lblStatusTitle.topAnchor.constraint(equalTo: bookingSeparator.bottomAnchor, constant: 10),
            
            lblStatus.trailingAnchor.constraint(lessThanOrEqualTo: lblDate.trailingAnchor, constant: 0),
            lblStatus.topAnchor.constraint(equalTo: lblStatusTitle.topAnchor),
            
            lblBookingStatus.trailingAnchor.constraint(equalTo: lblDate.trailingAnchor),
            lblBookingStatus.topAnchor.constraint(equalTo: lblStatus.bottomAnchor, constant: 5),
            
            bidderStackView.leadingAnchor.constraint(equalTo: statusSeparator.leadingAnchor),
            bidderStackView.trailingAnchor.constraint(equalTo: statusSeparator.trailingAnchor),
            
            statusSeparator.leadingAnchor.constraint(equalTo: lblBookingID.leadingAnchor),
            statusSeparator.trailingAnchor.constraint(equalTo: lblDate.trailingAnchor),
            statusSeparator.topAnchor.constraint(equalTo: bidderStackView.bottomAnchor, constant: 10),
            
            usersAndServicesStackView.leadingAnchor.constraint(equalTo: lblStatusTitle.leadingAnchor),
            usersAndServicesStackView.trailingAnchor.constraint(equalTo: lblStatusTitle.trailingAnchor),
            usersAndServicesStackView.topAnchor.constraint(equalTo: venueSeparator.bottomAnchor, constant: 15),
            
            venueView.leadingAnchor.constraint(equalTo: statusSeparator.leadingAnchor),
            venueView.trailingAnchor.constraint(equalTo: statusSeparator.trailingAnchor),
            venueView.topAnchor.constraint(equalTo: statusSeparator.bottomAnchor, constant: 17),
            
            venueSeparator.leadingAnchor.constraint(equalTo: lblBookingID.leadingAnchor),
            venueSeparator.trailingAnchor.constraint(equalTo: lblDate.trailingAnchor),
            venueSeparator.topAnchor.constraint(equalTo: venueView.bottomAnchor),
            
            buttonStackView.leadingAnchor.constraint(equalTo: usersAndServicesStackView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: usersAndServicesStackView.trailingAnchor),
            buttonStackView.topAnchor.constraint(equalTo: usersAndServicesStackView.bottomAnchor, constant: 20),
            
            scrollView.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 20)
            
        ])
        
        rxBinding()
        
        loadData()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(reloadBooking), name: .bookingDidUpdate, object: nil)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .bookingDidUpdate, object: nil)
    }
    
    public override func loadData() {
        _viewModel.execute(request: BookingListRequest(id: _id))
    }
    
    // MARK: - Selector
    @objc func reloadBooking() {
        _viewModel.execute(request: BookingListRequest(id: _id, forceReload: true))
    }
    
    @objc func artisanTapped() {
        guard let artisan = _booking?.artisan else { return }
        
//        delegate?.viewArtisan(artisan: artisan)
    }
    
    @objc func copyRefundCode() {
        guard let paymentCode = _paymentSummary?.payoutPasscode else { return }
        
        UIPasteboard.general.string = paymentCode
        
        view.makeToast("refund_code_copied".l10n())
    }
    
    @objc func complaintTapped() {
        guard let booking = _booking else { return }
        
//        let controller = PostComplaintViewController(id: booking.id)
//        controller.delegate = self
//        
//        let sheetController = SheetViewController(controller: controller)
//        
//        present(sheetController, animated: false, completion: nil)
    }
    
    @objc func reviewTapped() {
        guard
            let booking = _booking,
            let artisan = booking.artisan else { return }
        
//        delegate?.showRating(controller: self, booking: booking, artisan: artisan)
    }
    
    @objc func editTapped() {
        guard let booking = _booking else { return }
        
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        let editRequest = UIAlertAction(title: "edit_request".l10n(), style: .default) { _ in
            self.delegate?.editBooking(booking: booking)
        }
        
        let cancelRequest = UIAlertAction(title: "cancel_request".l10n(), style: .destructive) { _ in
            let confirmAlert = UIAlertController(title: "cancel_request".l10n(), message: "cancel_request_message".l10n(), preferredStyle: .actionSheet)
            
            var params : [String : Any] = [
                EventParams.bookingId.rawValue: self._id,
                EventParams.bookingStatus.rawValue: booking.bookingStatus?.id.rawValue
            ]
            
            if let artisan = booking.artisan {
                params[EventParams.artisanId.rawValue] = artisan.id
            }
            
            self.trackEvent(name: EventNames.cancelCustomRequestConfirmation.rawValue, extraParams: params)
            
            let yes = UIAlertAction(title: "yes".l10n(), style: .destructive) { _ in
                
                booking.bookingStatus?.id = .canceledByCustomer
                
                self.trackEvent(name: EventNames.cancelCustomRequestFinished.rawValue, extraParams: params)
                
//                self._updateViewModel.execute(request: (BookingListRequest(statuses: [.canceledByCustomer], bookingType: .booking, id: booking.id, artisanId: booking.artisan?.id), nil))
            }
            
            let cancel = UIAlertAction(title: "close".l10n(), style: .cancel)
            
            confirmAlert.addAction(yes)
            confirmAlert.addAction(cancel)
            
            self.present(confirmAlert, animated: true, completion: nil)
        }
        
        let close = UIAlertAction(title: "close".l10n(), style: .cancel)
        
        alert.addAction(editRequest)
        alert.addAction(cancelRequest)
        alert.addAction(close)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func refund() {
        guard let url = _paymentSummary?.refundURL else { return }
        
        checkout(title: "refund".l10n(), url: url)
    }
    
    @objc func goToPayment() {
        guard let url = _paymentSummary?.invoiceURL else { return }
        
        checkout(title: "payment".l10n(), url: url)
    }
    
    @objc func cancel(_ view: UIButton) {
//        guard let booking = _booking else { return }
//
//        let status: Booking.Status
//
//        if _userKind == .artisan {
//            status = .canceledByCustomer
//        } else {
//            status = .canceledByArtisan
//        }
//
//        trackBookingStatusUpdate(id: booking.id, customerId: booking.customer.id, status: status, confirmation: false)
//
//        let alert = UIAlertController(title: nil,
//                                      message: "cancel_booking_message".l10n(),
//                                      preferredStyle: .actionSheet)
//
//        let update = UIAlertAction(title: "cancel_booking".l10n().capitalized, style: .destructive) { _ in
//            booking.bookingStatus.id = status
//
//            self._updateViewModel.execute(request: (
//                bookingListRequest: BookingListRequest(statuses: [booking.bookingStatus.id],
//                                                                                   bookingType: .booking,
//                                                                                   id: booking.id,
//                                                                                   artisanId: booking.artisan?.id),
//                                            checkAvailabilityRequest: nil))
//        }
//
//        let cancel = UIAlertAction(title: "close".l10n(), style: .cancel)
//
//        alert.addAction(update)
//        alert.addAction(cancel)
//
//        present(alert, animated: true, completion: nil)
    }
    
    @objc func updateStatus(_ button: UIButton) {
        guard let booking = _booking else { return }
        
        let message: String
        let style: UIAlertAction.Style
        
        if booking.nextBookingStatus == .process && !booking.isAbleToProcess && button.tag != Booking.Status.canceledByCustomer.rawValue && button.tag != Booking.Status.canceledByArtisan.rawValue {
            
            let alert = UIAlertController(title: "information".l10n(),
                                          message: "unable_to_process_booking_message".l10n(),
                                          preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "ok".l10n(), style: .default)
            
            alert.addAction(ok)
            
            present(alert, animated: true, completion: nil)
            
            return
        }
//            else if booking.nextBookingStatus == .bid && !booking.hasBid {
//            let dialogView = bidRequestDialogView
//            
//            if !view.subviews.contains(dialogView) {
//                view.addSubview(dialogView)
//                
//                NSLayoutConstraint.activate([
//                    dialogView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                    dialogView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//                    dialogView.topAnchor.constraint(equalTo: view.topAnchor),
//                    dialogView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//                ])
//            }
//            
//            dialogView.price = booking.totalPrice.doubleValue
//            
//            dialogView.show(isShow: true, completion: { _ in
//                dialogView.firstResponder = true
//            })
//            
//            return
//        }
        
        if button.tag == Booking.Status.canceledByCustomer.rawValue {
            message = "cancel_booking_message".l10n()
            style = .destructive
        } else if button.tag == Booking.Status.canceledByArtisan.rawValue {
            message = "cancel_request_message".l10n()
            style = .destructive
        } else {
            message = booking.isRequestNotAccepted ? "confirm_customize_request_status_update_message".l10n(args: [button.titleLabel?.text?.lowercased() ?? ""]) : "confirm_booking_status_update_message".l10n(args: [button.titleLabel?.text?.lowercased() ?? ""])
            style = .default
        }
        
//        trackBookingStatusUpdate(id: booking.id, customerId: booking.customer.id, status: booking.nextBookingStatus, confirmation: false)
        
        showConfirmationAlert(message: message, style: style, buttonTitle: button.titleLabel?.text, booking: booking, statusId: button.tag, bidPrice: nil)
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - BookingVenueViewDelegate
    public func locationTapped(location: CLLocationCoordinate2D) {
        openMaps(name: venueView.lblVenue.lblText.text, coordinates: location)
    }
    
    // MARK: - PostComplaintViewControllerDelegate
    func complaintDidSend(id: Int, reason: String) {
//        guard let viewController = presentedViewController as? SheetViewController, let booking = _booking else { return }
//
//        viewController.closeSheet()
//
//        booking.status = .complaint
//        //TODO: Handle Update Booking
//        _cache?.update(model: booking)
//        loadData()
        
    }
    
    // MARK: - BookingUserViewDelegate
    func viewArtisan(artisan: Artisan) {
        delegate?.viewArtisan(artisan: artisan)
    }
    
    func acceptBid(view: BookingUserView, from artisan: Artisan) {
        guard let booking = _booking else { return }
        
//        let params : [String : Any] = [
//            EventParams.bookingId.rawValue: booking.id,
//            EventParams.customerId.rawValue: booking.customer.id,
//            EventParams.bookingStatus.rawValue: booking.status.rawValue,
//            EventParams.artisanId.rawValue: artisan.id
//        ]
//
//        trackEvent(name: EventNames.acceptCustomRequestConfirmation.rawValue, extraParams: params)
//
//        let alert = UIAlertController(title: "accept_bid".l10n(),
//                                      message: "accept_bid_from_x_confirmation".l10n(args: [artisan.name]),
//                                      preferredStyle: .actionSheet)
//
//        let accept = UIAlertAction(title: "accept".l10n(), style: .default) { _ in
//            self._acceptedArtisan = artisan
//            self._getPaymentURLViewModel.execute(request: PaymentRequest(bookingId: booking.id, artisanId: artisan.id, refund: false))
//        }
//
//        alert.addAction(accept)
//
//        alert.addAction(UIAlertAction(title: "cancel".l10n(), style: .cancel))
//
//        present(alert, animated: true, completion: nil)
    }
    
    func showContactOptions(name: String, phone: String) {
        let alert = UIAlertController(title: "contact_options".l10n(),
                                      message: "choose_your_contact_options".l10n(args: [phone]),
                                      preferredStyle: .actionSheet)
        
        let call = UIAlertAction(title: "call".l10n(), style: .default) { _ in
            if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        
        let sms = UIAlertAction(title: "sms".l10n(), style: .default) { _ in
            if MFMessageComposeViewController.canSendText() {
                let controller = MFMessageComposeViewController()
                controller.recipients = [phone]
                controller.messageComposeDelegate = self
                
                self.present(controller, animated: true, completion: nil)
            }
        }
        
        let whatsapp = UIAlertAction(title: "whatsapp".l10n(), style: .default) { _ in
            if let url = URL(string: "whatsapp://send?phone=\(phone)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.open(URL(string: "config.third_parties.whatsapp".l10n())!)
            }
        }
        
        let cancel = UIAlertAction(title: "close".l10n(), style: .cancel)
        
        alert.addAction(call)
        alert.addAction(sms)
        alert.addAction(whatsapp)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - CheckoutViewControllerDelegate
    public func dismissCheckout() {
        dismiss(animated: true, completion: nil)
    }
    
    public func checkoutSuccess() {
        guard let booking = _booking else { return }
        
//        if let artisan = _acceptedArtisan, booking.isCustom {
//            dismiss(animated: true)
//
//            let alert = UIAlertController(title: "payment_success".l10n(),
//                                          message: "bid_from_x_has_been_fully_paid".l10n(args: [artisan.name]),
//                                          preferredStyle: .alert)
//
//            let ok = UIAlertAction(title: "ok".l10n(), style: .default)
//
//            alert.addAction(ok)
//
//            present(alert, animated: true)
//
//            let params : [String : Any] = [
//                EventParams.bookingId.rawValue: booking.id,
//                EventParams.customerId.rawValue: booking.customer.id,
//                EventParams.bookingStatus.rawValue: booking.status.rawValue,
//                EventParams.artisanId.rawValue: booking.artisan?.id ?? 0
//            ]
//
//            trackEvent(name: EventNames.acceptCustomRequestFinished.rawValue, extraParams: params)
//
//            bidderStackView.arrangedSubviews.forEach { view in
//                UIView.animate(withDuration: 0.3) {
//                    if view.tag == artisan.id, let bidderView = view as? BookingUserView {
//                        bidderView.accept = true
//                        self.lblStatus.text = "accepted".l10n()
//                        self.lblBookingStatus.alpha = 0.0
//                        self.serviceSummaryView.lblTotalBookingFees.price = bidderView.price
//                    } else {
//                        view.isHidden = true
//                        view.alpha = 0.0
//
//                        self.bidderStackView.layoutIfNeeded()
//                    }
//                }
//            }
//
//            delegate?.statusUpdated(booking: booking)
//
//        } else if !booking.isCustom {
//            let controller = BookingSuccessViewController(booking: booking)
//
//            controller.title = "payment_success".l10n()
//
//            let navigationController = UINavigationController(rootViewController: controller)
//
//            navigationController.modalPresentationStyle = .fullScreen
//
//            visibleController?.present(navigationController, animated: true)
//
//            booking.paymentStatus = .paid
//
//            showDetail(booking)
//            //TODO: Handle Update Booking Status
////            _cache?.update(model: booking)
//
//            delegate?.paymentUpdated(booking: booking)
//        }
    }
    
    public func checkoutFailed() {
        dismissCheckout()
    }
    
    // MARK: - BidRequestDialogViewDelegate
    func cancelBid() {
        bidRequestDialogView.show(isShow: false)
    }
    
    func continueBid(price: Double?) {
        guard let booking = _booking else { return }
        
//        trackBookingStatusUpdate(id: booking.id, customerId: booking.customer.id, status: booking.nextBookingStatus, confirmation: false)
        
//        booking.status = booking.nextBookingStatus
        
        showConfirmationAlert(message: "confirm_booking_status_update_message".l10n(args: ["bid".l10n()]), style: .default, buttonTitle: "bid".l10n(), booking: booking, statusId: Booking.Status.open.rawValue, bidPrice: price)
    }
    
    // MARK: - Public
    public func toggleReviewButton(isEnabled: Bool) {
        if isViewLoaded {
            btnReview.isEnabled = isEnabled
            btnComplaint.isEnabled = isEnabled
        }
    }
    
    // MARK: - Private
    private func rxBinding() {
        _getPaymentURLViewModel.loading.drive(onNext: { [weak self] loading in
            guard let strongSelf = self else { return }
            
            strongSelf.btnPayment.toggleLoading(loading: loading)
            strongSelf.btnRefund.toggleLoading(loading: loading)
            
            strongSelf.bidderStackView.arrangedSubviews.forEach {
                if let view = $0 as? BookingUserView {
                    view.isEnabled = !loading.start
                }
            }
        }).disposed(by: disposeBag)
        
        _getPaymentURLViewModel.result.drive(onNext: { [weak self] (_, summary) in
            guard let strongSelf = self,
                  let paymentSummary = summary.data?.paymentSummary,
                  !paymentSummary.invoices.isEmpty else { return }
            
            strongSelf._paymentSummary = paymentSummary
            strongSelf.showPaymentSummary(paymentSummary)
            
            if strongSelf._acceptedArtisan != nil {
                strongSelf.goToPayment()
            }
        }).disposed(by: disposeBag)
        
        _viewModel.loading.drive(view.rx.toggleSkeletonLoading).disposed(by: disposeBag)
        _viewModel.result.drive(onNext: { [weak self] (_, detail) in
            guard let strongSelf = self, let booking = detail.data?.booking else { return }
            
            strongSelf.showPaymentSummary(detail.data?.paymentSummary)
            strongSelf.showDetail(booking)
            
//            if booking.showPayment {
//                strongSelf._getPaymentURLViewModel.execute(request: PaymentRequest(bookingId: booking.id, artisanId: nil, refund: false))
//            } else if detail.data?.paymentSummary?.isRefundable == true {
//                strongSelf._getPaymentURLViewModel.execute(request: PaymentRequest(bookingId: booking.id, artisanId: nil, refund: true))
//            }
            
        }).disposed(by: disposeBag)
        
        _updateViewModel.loading.drive(onNext: { [weak self] loading in
            guard let strongSelf = self else { return }
            
            strongSelf.btnUpdateStatus.toggleLoading(loading: loading)
            strongSelf.btnCancel.toggleLoading(loading: loading)
            
            strongSelf.bidderStackView.arrangedSubviews.forEach {
                if let view = $0 as? BookingUserView {
                    view.isEnabled = !loading.start
                }
            }
        }).disposed(by: disposeBag)
        
        _updateViewModel.failed.drive(onNext: { [weak self] error in
            guard let strongSelf = self, let booking = strongSelf._booking else { return }
            
//            booking.status = booking.revertBookingStatus
            
            let alert = UIAlertController(title: "information".l10n(),
                                          message: "unable_to_update_booking_status".l10n(),
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "ok".l10n(), style: .default))
            
            strongSelf.present(alert, animated: true, completion: nil)
            
            strongSelf.updateButton()
        }).disposed(by: disposeBag)
        
        _updateViewModel.exception.drive(onNext: { [weak self] error in
            guard let strongSelf = self, let booking = strongSelf._booking else { return }
            
//            let params : [String : Any] = [
//                EventParams.bookingId.rawValue: booking.id,
//                EventParams.customerId.rawValue: booking.customer.id,
//                EventParams.bookingStatus.rawValue: booking.status.rawValue
//            ]
//
//            booking.status = booking.revertBookingStatus
//
//            if let _ = error as? StatusError {
//
//                strongSelf.trackEvent(name: booking.isRequestNotAccepted ? EventNames.bidCustomRequestClashConfirmation.rawValue : EventNames.confirmBookingScheduleClashConfirmation.rawValue, extraParams: params)
//
//                let alert = UIAlertController(title: "information".l10n(),
//                                              message: "check_availability_schedule".l10n(args: [
//                                                                                            booking.start.toFullDate,
//                                                                                            booking.nextBookingAction.lowercased(),
//                                                                                            booking.isRequestNotAccepted ? "request".l10n().lowercased() : "booking".l10n().lowercased()]),
//                                              preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: "check_schedule".l10n(), style: .default, handler: { _ in
//                    strongSelf.trackEvent(name: EventNames.checkCalendar.rawValue, extraParams: params)
//
//                    strongSelf.delegate?.showCalendar(date: booking.start)
//                }))
//
//                alert.addAction(UIAlertAction(title: booking.nextBookingAction, style: .default, handler: { _ in
//                    booking.status = booking.nextBookingStatus
//
//                    strongSelf.trackEvent(name: booking.isRequestNotAccepted ? EventNames.bidCustomRequestClashProceed.rawValue : EventNames.confirmBookingScheduleClashProceed.rawValue, extraParams: params)
//
//                    strongSelf._updateViewModel.execute(request: (
//                                                            bookingListRequest: BookingListRequest(statuses: [booking.status],
//                                                                                                   bookingType: booking.isRequestNotAccepted ? .customizeRequest : .booking,
//                                                                                                   id: booking.id,
//                                                                                                   artisanId: booking.artisan?.id),
//                                                            checkAvailabilityRequest: nil)
//                    )
//                }))
//
//                alert.addAction(UIAlertAction(title: "cancel".l10n(), style: .cancel, handler: { _ in
//                    strongSelf.trackEvent(name: booking.isRequestNotAccepted ? EventNames.bidCustomRequestClashCancel.rawValue : EventNames.confirmBookingScheduleClashCancel.rawValue, extraParams: params)
//                }))
//
//                strongSelf.present(alert, animated: true, completion: nil)
//            } else {
//                let alert = UIAlertController(title: "update_failed".l10n(),
//                                              message: "update_error_message".l10n(),
//                                              preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: "ok".l10n(), style: .default))
//
//                strongSelf.present(alert, animated: true, completion: nil)
//            }
//
//            strongSelf.updateButton()
            
        }).disposed(by: disposeBag)
        
        _updateViewModel.result.drive(onNext: { [weak self] detail in
            guard
                let strongSelf = self,
                let statuses = detail.0?.bookingListRequest.bookingStatuses,
                let booking = detail.1.data?.booking, !statuses.isEmpty
            else { return }
            
            strongSelf._booking = booking
            
//            strongSelf.lblStatus.text = booking.bookingStatusDetailed
//
//            if booking.status.isCanceled && booking.paymentStatus != .refunded {
//                booking.paymentStatus = .toRefund
//                //TODO: Handle Update Booking Row
////                strongSelf._cache?.update(model: booking)
//                strongSelf._getPaymentURLViewModel.execute(request: PaymentRequest(bookingId: booking.id, artisanId: nil, refund: true))
//
//                strongSelf.serviceSummaryView.booking = booking
//                strongSelf.btnRefund.isHidden = strongSelf._userKind == .customer
//            }
//
//            strongSelf.updateButton()
//
//            let message: String
//
//            if statuses[0] == .canceledByArtisan && booking.isRequestNotAccepted && booking.status == .bid {
//                strongSelf.trackBookingStatusUpdate(id: booking.id, customerId: booking.customer.id, status: .canceledByArtisan, confirmation: true)
//
//                message = "bid_x_canceled".l10n(args: [booking.invoice])
//            } else if statuses[0] == .canceledByCustomer && booking.isRequestNotAccepted {
//                strongSelf.trackBookingStatusUpdate(id: booking.id, customerId: booking.customer.id, status: .canceledByCustomer, confirmation: true)
//
//                message = "bid_x_canceled".l10n(args: [booking.invoice])
//            } else if booking.status == .bid {
//                strongSelf.trackBookingStatusUpdate(id: booking.id, customerId: booking.customer.id, status: booking.status, confirmation: true)
//
//                message = "you_have_successfully_bid_x".l10n(args: [booking.invoice])
//            } else {
//                strongSelf.trackBookingStatusUpdate(id: booking.id, customerId: booking.customer.id, status: booking.status, confirmation: true)
//
//                message = "booking_with_x_status_x".l10n(args: [booking.invoice, booking.bookingStatus.lowercased()])
//            }
            
//            let alert = UIAlertController(title: "booking_status".l10n(),
//                                          message: message,
//                                          preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "ok".l10n(), style: .default))
//
//            strongSelf.present(alert, animated: true, completion: nil)
//
//            strongSelf.delegate?.statusUpdated(booking: booking)
            
        }).disposed(by: disposeBag)
        
        _bidderViewModel.exception.drive(onNext: { [weak self] _ in
            self?.showLoadBidderError()
        }).disposed(by: disposeBag)
        
        _bidderViewModel.failed.drive(onNext: { [weak self] _ in
            self?.showLoadBidderError()
        }).disposed(by: disposeBag)
        
        _bidderViewModel.result.drive(onNext: { [weak self] results in
            guard let strongSelf = self, let bids = results.1.data?.list else { return }
            
            strongSelf.lblStatus.text = "x_beauty_artisan".l10nPlural(args: [bids.count])
            strongSelf.lblStatus.textColor = UIColor.BeautyBell.accent
            strongSelf._stackViewTopConstraint.constant = 15
            
            strongSelf.bidderStackView.removeAllArrangedSubviews()
            
            bids.forEach {
                let v = BookingUserView(kind: .artisan)
                
                v.alpha = 0.0
                v.translatesAutoresizingMaskIntoConstraints = false
                v.artisan = $0.artisan
                v.price = $0.price
                v.delegate = self
                v.tag = $0.artisan.id
                
                strongSelf.bidderStackView.addArrangedSubview(v)
                
                UIView.animate(withDuration: 0.5) {
                    v.alpha = 1.0
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func showConfirmationAlert(message: String, style: UIAlertAction.Style, buttonTitle: String?, booking: Booking, statusId: Int, bidPrice: Double?) {
        let alert = UIAlertController(title: "confirm_status_update".l10n(),
                                      message: message,
                                      preferredStyle: .actionSheet)
        
        let update = UIAlertAction(title: buttonTitle, style: style) { _ in
            // Hide bid dialog
            if bidPrice != nil {
                self.bidRequestDialogView.show(isShow: false)
            }
            
            let isRequestNotAccepted = booking.isRequestNotAccepted
            
            let checkAvailabilityRequest: CheckAvailabilityRequest?
            
//            if statusId == Booking.Status.canceledByCustomer.rawValue {
//                booking.status = .canceledByCustomer
//                checkAvailabilityRequest = nil
//            } else if statusId == Booking.Status.canceledByArtisan.rawValue {
//                booking.status = .canceledByArtisan
//                checkAvailabilityRequest = nil
//            } else {
//                booking.status = booking.nextBookingStatus
//
//                if booking.status == .confirmed || booking.status == .bid {
//                    if !booking.isCustom && booking.status == .confirmed {
//                        checkAvailabilityRequest = CheckAvailabilityRequest(
//                            artisanId: booking.artisan?.id ?? 0,
//                            timeStart: booking.start.toUTC,
//                            serviceRequests: booking.serviceIdAndQuantities?.map({ CheckAvailabilityRequest.ServiceRequest(serviceId: $0.serviceId, quantity: $0.quantity) }),
//                            customRequestServiceRequests: nil)
//                    } else {
//                        checkAvailabilityRequest = CheckAvailabilityRequest(
//                            artisanId: booking.artisan?.id ?? self._preference.userId,
//                            timeStart: booking.start.toUTC,
//                            serviceRequests: nil,
//                            customRequestServiceRequests: [CheckAvailabilityRequest.CustomRequestServiceRequest(
//                                                            categoryTypeId: booking.customizeRequestServices?.first?.serviceId ?? 0,
//                                                            quantity: booking.customizeRequestServices?.first?.quantity ?? 0)])
//
//                    }
//                } else {
//                    checkAvailabilityRequest = nil
//                }
//            }
//
//            self._updateViewModel.execute(request: (
//                                            bookingListRequest: BookingListRequest(statuses: [booking.status],
//                                                                                   bookingType: isRequestNotAccepted ? .customizeRequest : .booking,
//                                                                                   id: booking.id,
//                                                                                   artisanId: booking.artisan?.id,
//                                                                                   bidPrice: bidPrice),
//                                            checkAvailabilityRequest: checkAvailabilityRequest))
        }
        
        let cancel = UIAlertAction(title: "close".l10n(), style: .cancel)
        
        alert.addAction(update)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showLoadBidderError() {
        
        let alert = UIAlertController(title: "update_failed".l10n(),
                                      message: "load_bidder_failed_message".l10n(),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "ok".l10n(), style: .default, handler: { _ in
            self.delegate?.loadBidderFailed()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func updateButton() {
        guard let booking = _booking else { return }
        
        profileView.btnPhone.isHidden = !booking.isContactable
        
        if _userKind == .artisan {
            lblBookingStatus.isHidden = false
            btnPayment.isHidden = true
            btnRefund.isHidden = true
            btnUpdateStatus.isHidden = true
            btnCancel.isHidden = !booking.isCancelable
//            btnReview.isHidden = booking.status != .completed
//            btnComplaint.isHidden = booking.status != .completed || booking.hasReview
            
            btnReview.isEnabled = !booking.hasReview
            
//            if booking.status == .complaint || booking.hasReview{
//                btnReview.isHidden = true
//                btnComplaint.isHidden = true
//            }
//
//            if booking.status == .open || booking.status == .bid{
//                lblBookingStatus.text = booking.bookingStatus
//            } else {
//                _stackViewTopConstraint.constant =  -(lblBookingStatus.frame.height+7)
//                lblBookingStatus.isHidden = true
//                btnUpdateStatus.isHidden = true
//            }
//
//            if booking.showPayment {
//                btnRefund.isHidden = true
//                btnPayment.isHidden = false
//            } else if _paymentSummary?.isRefundable == true {
//                btnPayment.isHidden = true
//                btnRefund.isHidden = false
//            }
          
            let moreButton = UIImage(named: "ic_more", bundle: CustomButton.self)

            navigationItem.rightBarButtonItem =
                    booking.isEditable ? UIBarButtonItem(image: moreButton, style: .plain, target: self, action: #selector(editTapped)) : nil
          
        } else {
            lblBookingStatus.isHidden = true
            btnUpdateStatus.isEnabled = true
            btnUpdateStatus.isHidden = false
//            btnUpdateStatus.text = booking.nextBookingAction
            btnReview.isHidden = true
            btnComplaint.isHidden = true
            btnCancel.isHidden = !booking.isCancelableByArtisan
            
            _stackViewTopConstraint.constant =  -(lblBookingStatus.frame.height+7)
            
//            if booking.status == .booking{
//                btnCancel.text = "reject".l10n()
//            }else if booking.status == .confirmed{
//                btnCancel.text = "cancel".l10n()
//            }
//
//            if booking.status.isCompleted || booking.status.isComplained || booking.status.isCanceled || booking.alreadyBid {
//                btnUpdateStatus.isHidden = true
//            } else if booking.isExpired {
//                btnUpdateStatus.isEnabled = false
//            }
        }
        
        venueView.booking = booking
    }
    
    private func showDetail(_ detail: Booking) {
//        _booking = detail
//
//        let text = "booking_id_x".l10n(args: [detail.invoice])
//        let attributedString = NSMutableAttributedString(string: text)
//
//        let ranges = text.ranges(of: "booking_id_colon".l10n())
//
//        ranges.forEach {
//            attributedString.addAttributes([.foregroundColor: UIColor.BeautyBell.gray500], range: NSRange($0, in: text))
//        }
//
//        btnUpdateStatus.isHidden = false
//        lblBookingID.attributedText = attributedString
//        lblDate.text = detail.createdAt.toMediumDate
//        lblStatus.text = detail.bookingStatusDetailed
//
//        if _userKind == .artisan {
//            profileView.isHidden = detail.artisan == nil
//
//            profileView.artisan = detail.artisan
//        } else {
//            profileView.customer = detail.customer
//        }
//
//        reviewView.isHidden = !detail.hasReview
//        reviewView.review = detail.review
//        complaintView.isHidden = detail.status != .complaint
//        complaintView.complaint = detail.complaint
//
//        venueView.booking = detail
//        serviceSummaryView.booking = detail
//
//        updateButton()
//
//        if _bidderList == nil, detail.status == .bid && _userKind == .artisan {
//            _bidderViewModel.execute(request: detail.id)
//        }
    }
    
    private func showPaymentSummary(_ paymentSummary: PaymentSummary?) {
        
        _paymentSummary = paymentSummary
        
        if let paymentSummary = paymentSummary, paymentSummary.isPaymentPaid {
            paymentSummaryView.isHidden = false
            paymentSummaryView.paymentSummary = paymentSummary
            
            btnRefund.isHidden = !paymentSummary.isRefundable || _userKind == .customer
            
            if let passcode = paymentSummary.payoutPasscode, !btnRefund.isHidden {
                lblRefundInfo.isHidden = false
                
                let text = "refund_info".l10n(args: [passcode])
                
                lblRefundInfo.setTextWithLink(text: text, link: passcode, font: mediumBody1)
            }
            
        } else {
            paymentSummaryView.isHidden = true
        }
    }
    
    private func trackBookingStatusUpdate(id: Int, customerId: Int, status: Booking.Status, confirmation: Bool) {
        guard let booking = _booking else { return }
        
        var eventName: String?
        
        switch status {
        case .bid: eventName = !confirmation ? EventNames.bidCustomRequestConfirmation.rawValue : EventNames.bidCustomRequestFinished.rawValue
        case .confirmed: eventName = !confirmation ? EventNames.confirmBookingConfirmation.rawValue : EventNames.confirmBookingFinished.rawValue
        case .process: eventName = !confirmation ? EventNames.processBookingConfirmation.rawValue : EventNames.processBookingFinished.rawValue
        case .completed: eventName = !confirmation ? EventNames.completeBookingConfirmation.rawValue : EventNames.completeBookingFinished.rawValue
        case .canceledByArtisan: eventName = !confirmation ? EventNames.cancelBookingByArtisanConfirmation.rawValue : EventNames.cancelBookingByArtisanFinished.rawValue
        case .canceledByCustomer:
            if !confirmation {
                eventName = booking.isRequestNotAccepted ? EventNames.cancelCustomRequestConfirmation.rawValue : EventNames.cancelBookingByCustomerConfirmation.rawValue
            } else {
                eventName = booking.isRequestNotAccepted ? EventNames.cancelCustomRequestFinished.rawValue : EventNames.cancelBookingByCustomerFinished.rawValue
            }
        default: break
        }
        
        if let name = eventName {
            let params : [String : Any] = [
                EventParams.bookingId.rawValue: id,
                EventParams.customerId.rawValue: customerId,
                EventParams.bookingStatus.rawValue: status.rawValue
            ]
            
            trackEvent(name: name, extraParams: params)
        }
    }
    
    private func checkout(title: String, url: URL) {
        guard let paymentSummary = _paymentSummary else { return }
        
        let controller = CheckoutViewController(successURL: paymentSummary.successURL, failedURL: paymentSummary.failedURL, url: url)
        
        controller.title = title
        controller.delegate = self
        
        let navigationController = UINavigationController(rootViewController: controller)
        
        navigationController.modalPresentationStyle = .fullScreen
        
        present(navigationController, animated: true)
    }
}
