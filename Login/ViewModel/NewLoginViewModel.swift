//
//  LoginCustomerViewModel.swift
//  Login
//
//  Created by Reyhan Rifqi Azzami on 08/02/22.
//  Copyright © 2022 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Domain
import L10n_swift
import Platform
import ServiceWrapper
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices

public struct NewLoginViewModel: LoginViewModelType, LoginViewModelOutput {
    public typealias T = Token
    
    public typealias Outputs = NewLoginViewModel
    
    public var outputs: Outputs { return self }
    
    // MARK: - Outputs
    public let validatedEmail: Driver<ValidationResult>
    public let validatedPassword: Driver<ValidationResult>
    public let loginEnabled: Driver<Bool>
    
    public let login: Driver<Void>
    
    public let loading: Driver<Loading>
    public var unauthorized: Driver<Unauthorized>
    public let exception: Driver<Exception>
    public let success: Driver<T>
    public let failed: Driver<ValidationResult>
    
    public let dismissResponder: Driver<Bool>
    
    var signInConfig: GIDConfiguration?
    
    private let _requestProperty = PublishSubject<ServiceWrapper.LoginRequest>()
    private let _userKind: User.Kind
    
    public init<U: UseCase>(
        email: Driver<String?>,
        password: Driver<String?>,
        useCase: U, userKind: User.Kind = .customer
        ) where U.R == ServiceWrapper.LoginRequest, U.T == T, U.E == Error {
            
        _userKind = userKind
        
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<T>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        let exceptionProperty = PublishSubject<Exception>()
        let dismissResponderProperty = PublishSubject<Bool>()
        let failedProperty = PublishSubject<ValidationResult>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        dismissResponder = dismissResponderProperty.asDriver(onErrorJustReturn: false)
            failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        
        validatedEmail = email.flatMapLatest { email in
            guard let email = email else { return .empty() }
            if email.isEmpty {
                return .just(.empty)
            } else if email.isValidEmail {
                return .just(.ok(message: nil))
            } else {
                return .just(.failed(message: "invalid_email".l10n()))
            }
        }
        
        validatedPassword = password.flatMapLatest { value in
            guard let value = value else { return .empty() }
            if value.isEmpty {
                return .just(.empty)
            } else if !value.validPassword {
                return .just(.failed(message: "invalid_password".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
    
        loginEnabled = Driver.combineLatest(validatedEmail, validatedPassword) {
            email, password in
            
            email.isValid && password.isValid
            
            }.distinctUntilChanged()
            
        if let path =
            Bundle.main.path(forResource: "FirebaseDefault", ofType: "plist"),
            let dictionary = NSDictionary(contentsOfFile: path),
            let clientID = dictionary["google_client_id"] as? String {
            
            signInConfig = GIDConfiguration.init(clientID: clientID)
        }
        
        login = _requestProperty
                .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "logging_in".l10n()))
                dismissResponderProperty.onNext(true)
            })
            .flatMapLatest { request in
                return useCase.execute(request: request).asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false, text: "login".l10n())) })
                .flatMapLatest { result in
                switch result {
                case let .success(login):
                    successProperty.onNext(login)
                case let .error(error):
                    exceptionProperty.onNext(Exception(title: "login_failed".l10n(), message: "login_error_message".l10n(), error: error))
                case .unauthorized:
                    unauthorizedProperty.onNext(Unauthorized(title: "login_failed".l10n(), message: "login_unauthorized".l10n(), showLogin: false))
                case let .fail(status: response, errors: _):
                    failedProperty.onNext(.failed(message: response.message))
                }
                
                return .empty()
        }
    }
    
    public func execute(idetifier: String? = nil, password: String? = nil, grantType: ServiceWrapper.LoginRequest.Grant_Type? = .password){
        let request: ServiceWrapper.LoginRequest
        if idetifier == nil && password == nil{
            request = ServiceWrapper.LoginRequest(grantType: .guest)
        }else{
            request = ServiceWrapper.LoginRequest(identifier: idetifier, password: password, grantType: grantType!)
        }
        
        _requestProperty.onNext(request)
    }
    
    public func handleGoogleSigninRequest(vc: UIViewController) {
        guard let signInConfig = signInConfig else { return }
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: vc) { user, error in
            guard let idToken = user?.authentication.idToken else {
                return
            }
            switch _userKind{
            case .customer:
                execute(idetifier: idToken, grantType: .google)
            case .artisan:
                execute(idetifier: idToken, grantType: .artisanGoogle)
            }
        }
    }
    
    public func handleFacebookLoginRequest(vc: UIViewController) {
        LoginManager().logIn(permissions: ["public_profile", "email"], from: vc) { result, error in
            guard let token = result?.token?.tokenString else {
                return
            }
            switch _userKind{
            case .customer:
                execute(idetifier: token, grantType: .facebook)
            case .artisan:
                execute(idetifier: token, grantType: .artisanFacebook)
            }
        }
    }
    
    public func handleAppleidRequest(vc: UIViewController) {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = vc as? ASAuthorizationControllerDelegate
            authorizationController.performRequests()
        }
    }
    
}
