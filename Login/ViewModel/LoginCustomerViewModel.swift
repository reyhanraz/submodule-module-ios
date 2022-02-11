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

public struct LoginCustomerViewModel: LoginViewModelType, LoginViewModelOutput {
    public typealias T = Token
    
    public typealias Outputs = LoginCustomerViewModel
    
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
    
    public let dismissResponder: Driver<Bool>
    
    var signInConfig: GIDConfiguration?
    
    public init<U: UseCase>(
        email: Driver<String>,
        password: Driver<String>,
        loginSignal: Signal<()>,
        useCase: U
        ) where U.R == ServiceWrapper.LoginRequest, U.T == T, U.E == Error {
        
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<T>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        let exceptionProperty = PublishSubject<Exception>()
        let dismissResponderProperty = PublishSubject<Bool>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        dismissResponder = dismissResponderProperty.asDriver(onErrorJustReturn: false)
        
        validatedEmail = email.flatMapLatest { email in
            if email.isEmpty {
                return .just(.empty)
            } else if email.isValidEmail {
                return .just(.ok(message: nil))
            } else {
                return .just(.failed(message: "invalid_email".l10n()))
            }
        }
        
        validatedPassword = password.flatMapLatest { value in
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
        
        let forms = Driver.combineLatest(email, password) { email, password in
            ServiceWrapper.LoginRequest(identifier: email, password: password, grantType: .password)
        }
        
        login = loginSignal.withLatestFrom(forms)
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
                case let .success(register):
                    successProperty.onNext(register)
                case let .error(error):
                    exceptionProperty.onNext(Exception(title: "login_failed".l10n(), message: "login_error_message".l10n(), error: error))
                case .unauthorized:
                    unauthorizedProperty.onNext(Unauthorized(title: "login_failed".l10n(), message: "login_unauthorized".l10n(), showLogin: false))
                case .fail(status: _, errors: _):
                    unauthorizedProperty.onNext(Unauthorized(title: "login_failed".l10n(), message: "login_unauthorized".l10n(), showLogin: false))
                default:
                    return .empty()
                }
                
                return .empty()
        }
    }
    
    public func handleGoogleSigninRequest(vc: UIViewController) {
        guard let signInConfig = signInConfig else { return }
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: vc) { user, error in
            guard let idToken = user?.authentication.idToken else {
                return
            }
            
            // TODO: idtoken for identifier field (endpoint: accounts/login)
        }
    }
    
    public func handleFacebookLoginRequest(vc: UIViewController) {
        LoginManager().logIn(permissions: ["public_profile", "email"], from: vc) { result, error in
            guard let token = result?.token?.tokenString else {
                return
            }
            
            // TODO: token for identifier field (endpoint: accounts/login)
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
        } else {
            // Fallback on earlier versions
        }
    }
    
}
