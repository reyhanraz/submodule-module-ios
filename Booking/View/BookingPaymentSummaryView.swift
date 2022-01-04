//
// Created by Fandy Gotama on 13/01/20.
// Copyright (c) 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Payment

public class BookingPaymentSummaryView: UIView {

    let lblPaymentInfo: UILabel = {
        let v = UILabel()

        v.text = "payment_info".l10n()
        v.font = regularH6
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    let lblPaymentMethodTitle: UILabel = {
        let v = UILabel()

        v.isSkeletonable = true
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "payment_method".l10n()

        return v
    }()

    let lblPaymentMethod: UILabel = {
        let v = UILabel()

        v.isSkeletonable = true
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    let lblInvoiceTitle: UILabel = {
        let v = UILabel()

        v.isSkeletonable = true
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "payment_invoice_number".l10n()

        return v
    }()

    let lblInvoice: UILabel = {
        let v = UILabel()

        v.isSkeletonable = true
        v.font = regularBody1
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "       "

        return v
    }()

    let lblTotalPaymentTitle: UILabel = {
        let v = UILabel()

        v.isSkeletonable = true
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "total_payment".l10n()

        return v
    }()

    let topServiceSeparatorView: SeparatorView = {
        let v = SeparatorView()

        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    let lblTotalPayment: CurrencyLabel = {
        let v = CurrencyLabel()

        v.text = "   "
        v.isSkeletonable = true
        v.font = boldBody1
        v.textColor = UIColor.BeautyBell.accent
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    public var paymentSummary: PaymentSummary? {
        didSet {
            guard let paymentSummary = paymentSummary else { return }

            lblInvoice.text = paymentSummary.invoiceNumber
            lblTotalPayment.price = paymentSummary.paidAmount
            lblPaymentMethod.text = paymentSummary.paymentChannelAndMethod ?? "dash".l10n()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }

    public init() {
        super.init(frame: .zero)

        isSkeletonable = true

        addSubview(lblPaymentInfo)
        addSubview(topServiceSeparatorView)
        addSubview(lblInvoiceTitle)
        addSubview(lblInvoice)
        addSubview(lblPaymentMethodTitle)
        addSubview(lblPaymentMethod)
        addSubview(lblTotalPaymentTitle)
        addSubview(lblTotalPayment)

        layer.cornerRadius = 10
        layer.borderColor = UIColor.BeautyBell.gray300.cgColor
        layer.borderWidth = 1

        clipsToBounds = true

        NSLayoutConstraint.activate([
            lblPaymentInfo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            lblPaymentInfo.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            lblPaymentInfo.topAnchor.constraint(equalTo: topAnchor, constant: 10),

            topServiceSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topServiceSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topServiceSeparatorView.topAnchor.constraint(equalTo: lblPaymentInfo.bottomAnchor, constant: 10),

            lblInvoiceTitle.leadingAnchor.constraint(equalTo: lblPaymentInfo.leadingAnchor),
            lblInvoiceTitle.trailingAnchor.constraint(equalTo: lblPaymentInfo.trailingAnchor),
            lblInvoiceTitle.topAnchor.constraint(equalTo: topServiceSeparatorView.bottomAnchor, constant: 10),

            lblInvoice.leadingAnchor.constraint(equalTo: lblPaymentInfo.leadingAnchor),
            lblInvoice.trailingAnchor.constraint(equalTo: lblPaymentInfo.trailingAnchor),
            lblInvoice.topAnchor.constraint(equalTo: lblInvoiceTitle.bottomAnchor, constant: 5),

            lblPaymentMethodTitle.leadingAnchor.constraint(equalTo: lblPaymentInfo.leadingAnchor),
            lblPaymentMethodTitle.trailingAnchor.constraint(equalTo: lblPaymentInfo.trailingAnchor),
            lblPaymentMethodTitle.topAnchor.constraint(equalTo: lblInvoice.bottomAnchor, constant: 10),

            lblPaymentMethod.leadingAnchor.constraint(equalTo: lblPaymentInfo.leadingAnchor),
            lblPaymentMethod.trailingAnchor.constraint(equalTo: lblPaymentInfo.trailingAnchor),
            lblPaymentMethod.topAnchor.constraint(equalTo: lblPaymentMethodTitle.bottomAnchor, constant: 5),

            lblTotalPaymentTitle.leadingAnchor.constraint(equalTo: lblPaymentInfo.leadingAnchor),
            lblTotalPaymentTitle.trailingAnchor.constraint(equalTo: lblPaymentInfo.trailingAnchor),
            lblTotalPaymentTitle.topAnchor.constraint(equalTo: lblPaymentMethod.bottomAnchor, constant: 15),

            lblTotalPayment.leadingAnchor.constraint(equalTo: lblPaymentInfo.leadingAnchor),
            lblTotalPayment.trailingAnchor.constraint(equalTo: lblPaymentInfo.trailingAnchor),
            lblTotalPayment.topAnchor.constraint(equalTo: lblTotalPaymentTitle.bottomAnchor, constant: 5),

            bottomAnchor.constraint(equalTo: lblTotalPayment.bottomAnchor, constant: 10)
        ])
    }
}
