//
//  UpdateAddressViewController.swift
//  Address
//
//  Created by Fandy Gotama on 29/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Domain
import Platform
import CoreLocation
import MapKit
import LocationPicker

public protocol UpdateAddressViewControllerDelegate: class {
    func updateSuccess(address: Address)
}

public class UpdateAddressViewController: RxViewController, LabelTextFieldDelegate, LocationAdapterDelegate, LocationMapViewDelegate {
    private let _address: Address?
    
    let edtAddressName: LabelTextField = {
        let v = LabelTextField(title: "address_name".l10n(), keyboardType: .default, placeholder: "address_name_hint".l10n())
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let edtAddressDetail: LabelTextField = {
        let v = LabelTextField(title: "address".l10n(), keyboardType: .default, multiline: true, placeholder: "address_hint".l10n())
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let btnSubmit: CustomButton = {
        let v = CustomButton()
        
        v.displayType = .primary
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "submit".l10n()
        
        return v
    }()
    
    lazy var edtProvince: LabelTextField = {
        let v = LabelTextField(title: "province".l10n(), keyboardType: .default, placeholder: "province_hint".l10n(), isSelection: true)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        
        return v
    }()
    
    lazy var edtDistrict: LabelTextField = {
        let v = LabelTextField(title: "city".l10n(), keyboardType: .default, placeholder: "city_hint".l10n(), isSelection: true)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        
        return v
    }()
    
    lazy var edtSubDistrict: LabelTextField = {
        let v = LabelTextField(title: "district".l10n(), keyboardType: .default, placeholder: "district_hint".l10n(), isSelection: true)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        
        return v
    }()
    
    lazy var edtPostalCode: LabelTextField = {
        let v = LabelTextField(title: "postal_code".l10n(), keyboardType: .default, placeholder: "postal_code_hint".l10n(), isSelection: true)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        
        return v
    }()
    
    lazy var locationMapView: LocationMapView = {
        let v = LocationMapView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        
        v.addSubview(edtAddressName)
        v.addSubview(edtAddressDetail)
        v.addSubview(edtProvince)
        v.addSubview(edtDistrict)
        v.addSubview(edtSubDistrict)
        v.addSubview(edtPostalCode)
        v.addSubview(locationMapView)
        v.addSubview(btnSubmit)
        
        v.keyboardDismissMode = .interactive
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public weak var delegate: UpdateAddressViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    public init(address: Address? = nil) {
        _address = address
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            edtAddressName.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            edtAddressName.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            edtAddressName.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            
            edtAddressDetail.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            edtAddressDetail.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            edtAddressDetail.topAnchor.constraint(equalTo: edtAddressName.bottomAnchor, constant: 20),
            
            edtProvince.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            edtProvince.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            edtProvince.topAnchor.constraint(equalTo: edtAddressDetail.bottomAnchor, constant: 20),
            
            edtDistrict.leadingAnchor.constraint(equalTo: edtProvince.leadingAnchor),
            edtDistrict.trailingAnchor.constraint(equalTo: edtProvince.trailingAnchor),
            edtDistrict.topAnchor.constraint(equalTo: edtProvince.bottomAnchor, constant: 20),
            
            edtSubDistrict.leadingAnchor.constraint(equalTo: edtProvince.leadingAnchor),
            edtSubDistrict.trailingAnchor.constraint(equalTo: edtProvince.trailingAnchor),
            edtSubDistrict.topAnchor.constraint(equalTo: edtDistrict.bottomAnchor, constant: 20),
            
            edtPostalCode.leadingAnchor.constraint(equalTo: edtProvince.leadingAnchor),
            edtPostalCode.trailingAnchor.constraint(equalTo: edtProvince.trailingAnchor),
            edtPostalCode.topAnchor.constraint(equalTo: edtSubDistrict.bottomAnchor, constant: 20),
            
            locationMapView.leadingAnchor.constraint(equalTo: edtProvince.leadingAnchor),
            locationMapView.trailingAnchor.constraint(equalTo: edtProvince.trailingAnchor),
            locationMapView.topAnchor.constraint(equalTo: edtPostalCode.bottomAnchor, constant: 20),
            
            btnSubmit.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            btnSubmit.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            btnSubmit.topAnchor.constraint(equalTo: locationMapView.bottomAnchor, constant: 20),
            
            scrollView.bottomAnchor.constraint(equalTo: btnSubmit.bottomAnchor, constant: 10)
        ])
        
        rxBinding()
        
        if let address = _address {
            setAddress(address)
        }
    }
    
    // MARK: - LabelTextFieldDelegate
    public func viewTapped(field: LabelTextField) {
        let delegate = UIApplication.shared.delegate as! AppDelegateType
        
        let cache = LocationSQLCache<String>(dbQueue: delegate.dbQueue)
        
        let useCase = SearchUseCaseProvider(
            service: SearchLocationCloudService<List<Location>>(),
            cacheService: ListCacheService<String, List<Location>, LocationSQLCache<String>>(cache: cache),
            activityIndicator: activityIndicator)
        
        let adapter = LocationAdapter(cache: cache)
        
        adapter.delegate = self
        
        let controller = SearchViewController(
            with: LocationCell.self,
            useCase: useCase,
            dataSource: adapter,
            searchAfter: 2,
            placeholder: "search_city_province_postal".l10n(),
            rowHeight: 120)
        
        controller.title = "select_location".l10n()
        controller.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - LocationAdapaterDelegate
    public func locationTapped(_ location: Location) {
        navigationController?.popViewController(animated: true)
        
        edtProvince.text = location.provinceName
        edtDistrict.text = location.districtName
        edtSubDistrict.text = "\(location.urbanVillageName), \(location.subDistrictName)"
        edtPostalCode.text = location.postalCode
        
        edtProvince.selectionId = location.id
    }
    
    // MARK: - LocationMapViewDelegate
    public func locationTapped(location: CLLocationCoordinate2D?) {
      
        let locationPicker = LocationPickerViewController()
        
        let initialLocation: LocationPicker.Location?
        
        if let location = location {
            let placemark = MKPlacemark(coordinate: location, addressDictionary: nil)
            
            initialLocation = LocationPicker.Location(name: edtSubDistrict.text, location: nil, placemark: placemark)
        } else {
            initialLocation = nil
        }
        
        locationPicker.location = initialLocation
        locationPicker.selectCurrentLocationInitially = true
        locationPicker.mapType = .standard
        locationPicker.useCurrentLocationAsHint = true
        locationPicker.searchBarPlaceholder = "search_address".l10n()
        locationPicker.searchHistoryLabel = "search_history".l10n()
        locationPicker.completion = { location in
            self.locationMapView.location = location?.coordinate
        }
        
        let button = UIBarButtonItem(title: "back".l10n(), style: .plain, target: self, action: nil)
        
        navigationItem.backBarButtonItem = button
        
        navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    // MARK: - Private
    private func rxBinding() {
        let delegate = UIApplication.shared.delegate as! AppDelegateType
        
        let cache = AddressSQLCache<AddressRequest>(dbQueue: delegate.dbQueue)
        
        let useCase = UpdateAddressUseCaseProvider(
            service: UpdateAddressCloudService<AddressDetail>(),
            cache: cache,
            activityIndicator: activityIndicator)
        
        let viewModel = UpdateAddressViewModel<AddressDetail>(
            id: _address?.id,
            name: (edtAddressName.edtText.rx.textChange.asDriver(onErrorJustReturn: nil), CommonUIConfig.Validation.Name.min, CommonUIConfig.Validation.Name.max),
            detail: edtAddressDetail.edtTextView.textView.rx.text.orEmpty.asDriver(),
            areaId: edtProvince.rx.selectionId.asDriver(),
            coordinates: locationMapView.rx.coordinates.asDriver(),
            updateSignal: btnSubmit.rx.tap.asSignal(),
            useCase: useCase)
        
        viewModel.loading.drive(btnSubmit.rx.toggleLoading).disposed(by: disposeBag)
        viewModel.dismissResponder.drive(rx.endEditing).disposed(by: disposeBag)
        viewModel.updateEnabled.drive(btnSubmit.rx.isEnabled).disposed(by: disposeBag)
        viewModel.validatedAddressName.drive(edtAddressName.rx.validationResult).disposed(by: disposeBag)
        viewModel.validatedAddressDetail.drive(edtAddressDetail.rx.validationResult).disposed(by: disposeBag)
        viewModel.validatedCoordinates.drive(locationMapView.rx.validationResult).disposed(by: disposeBag)
        viewModel.exception.drive(rx.exception).disposed(by: disposeBag)
        viewModel.update.drive().disposed(by: disposeBag)
        
        viewModel.success.drive(onNext: { [weak self] address in
            guard
                let strongSelf = self,
                let address = address.data?.address else { return }
            
            let message = strongSelf._address != nil ? "update_address_success_message".l10n() : "add_address_success_message".l10n()
            
            strongSelf.showAlert(title: "information".l10n(), message: message, completion: nil) {
                strongSelf.delegate?.updateSuccess(address: address)
            }
        }).disposed(by: disposeBag)
        
        
        RxKeyboard.keyboardHeight()
            .subscribe(onNext: { [weak self] keyboardHeight in
                guard let strongSelf = self else { return }
                
                let height = keyboardHeight == 0 ? 0 : keyboardHeight
                
                strongSelf.scrollView.contentInset.bottom = height
                strongSelf.scrollView.scrollIndicatorInsets.bottom = height
                
                // Look for active responder, show field if hidden by keyboard
                for childView in strongSelf.scrollView.subviews {
                    if let textField = childView as? LabelTextField, textField.isFirstResponder {
                        var frame = strongSelf.scrollView.bounds
                        
                        frame.size.height -= keyboardHeight + strongSelf.scrollView.frame.origin.y
                        
                        if !frame.contains(textField.frame) {
                            let point = CGPoint.init(x: 0.0, y: textField.frame.origin.y - keyboardHeight + strongSelf.scrollView.frame.origin.y)
                            
                            strongSelf.scrollView.contentOffset = point
                        }
                        
                        break
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    private func setAddress(_ address: Address) {
       
        edtAddressName.text = address.name
        edtAddressDetail.text = address.detail
        edtProvince.text = address.provinceName
        edtDistrict.text = address.districtName
        edtSubDistrict.text = address.villageAndSubDistrict
        edtPostalCode.text = address.postalCode
        
        edtProvince.selectionId = address.areaId
        
        locationMapView.layoutIfNeeded()
        
        locationMapView.location = address.coordinates
    }
}
