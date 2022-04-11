//
//  ServiceWrapper.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 09/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation
import Platform
import Alamofire
import RxSwift

open class ServiceHelper{
    private let _user = UserPreference()
        
    public init(){
        
    }
        
    private static func dataRequest(_ urlString: String, method: HTTPMethod = .get, parameters: Parameters?, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders, onCompleted:@escaping (DataResponse<Any>) -> Void) -> DataRequest {
        AF.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers).responseJSON { response in
            #if DEBUG
            print("ServiceWrapper: Request Headers: \(response.request?.headers)")
            print("ServiceWrapper: Response: \(response.debugDescription)")
            #endif
            onCompleted(response)
        }
    }
    
    public func upload(host: URL, path: URL, header: HTTPHeaders) -> Observable<DataResponse<Any>>{
        return Observable<DataResponse<Any>>.create { observer in
            let request = AF.upload(path, to: host, method: .put, headers: header).responseJSON(completionHandler: { response in
                observer.onNext(response)
                observer.onCompleted()
            })
            
            return Disposables.create{
                request.cancel()
            }
        }
    }
    
    //Request Using Encodable Model
    public func request<R: Encodable> (_ endPoint: String,
                                       method: HTTPMethod = .get,
                                       parameter: R?,
                                       encoding: ParameterEncoding = URLEncoding.queryString,
                                       httpHeader: HTTPHeaders = HTTPHeaders(PlatformConfig.defaultHttpHeaders),
                                       isBasicAuth: Bool = false) -> Observable<DataResponse<Any>>  {
        
        let param = (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(parameter))) as? [String: Any] ?? [:]
        return request(endPoint,
                       method: method,
                       parameter: param,
                       encoding: encoding,
                       httpHeader: httpHeader,
                       isBasicAuth: isBasicAuth)
    }
    
    //Request Using Dict of Any
    public func request(_ endPoint: String,
                        method: HTTPMethod = .get,
                        parameter: [String: Any]?,
                        encoding: ParameterEncoding = URLEncoding.queryString,
                        httpHeader: HTTPHeaders = HTTPHeaders(PlatformConfig.defaultHttpHeaders),
                        isBasicAuth: Bool = false) -> Observable<DataResponse<Any>>  {
        
        let baseURL = "\(PlatformConfig.hostString)/\(endPoint)"
        
        var header = httpHeader
        let param = parameter
        
        if isBasicAuth{
            header.add(HTTPHeader.authorization(username: "web", password: "secret"))
            return Observable<DataResponse<Any>>.create { observer in
                let request = ServiceHelper.dataRequest(baseURL, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header) { response in
                    observer.onNext(response)
                    observer.onCompleted()
                }
                return Disposables.create{
                    request.cancel()
                }
            }
        } else if !_user.isTokenExpired{
            header.add(name: "Authorization", value: "\(_user.tokenType ?? "") \(_user.authorizationCode ?? "")")
            return Observable<DataResponse<Any>>.create { observer in
                let request = ServiceHelper.dataRequest(baseURL, method: method, parameters: param, encoding: encoding, headers: header) { response in
                    observer.onNext(response)
                    observer.onCompleted()
                }
                return Disposables.create {
                    request.cancel()
                }
            }
        }else{
            return Observable<DataResponse<Any>>.create {[weak self] observer in
                guard let strongSelf = self else {
                    return Disposables.create{ }
                }
                    
                let refreshToken: LoginRequest
                
                if strongSelf._user.isGuest{
                    refreshToken = LoginRequest(grantType: .guest)
                }else{
                    refreshToken = LoginRequest(identifier: strongSelf._user.authorizationCode,
                                                password: strongSelf._user.refreshToken,
                                                grantType: .refreshToken)
                }
                
                let loginParameter: [String: Any] = (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(refreshToken))) as? [String: Any] ?? [:]
                header.add(HTTPHeader.authorization(username: "web", password: "secret"))
                let request = ServiceHelper.dataRequest("\(PlatformConfig.hostString)/accounts/login", method: .post,parameters: loginParameter, encoding: JSONEncoding.default, headers: header) { response in
                    switch response.result{
                    case .success(_):
                        guard let data = response.data, let token = try? JSONDecoder().decode(Token.self, from: data) else {
                            switch response.response?.statusCode {
                            case 403:
                                return observer.onError(ServiceError.forbidden)
                            case 404:
                                return observer.onError(ServiceError.notFound)
                            default:
                                return observer.onError(AFError.explicitlyCancelled)
                            }
                        }
                        
                        self?._user.saveToken(accessToken: token.access_token, refreshToken: token.refresh_token, expiredTime: token.expires_in, tokenType: token.token_type)
                        
                        DispatchQueue.main.async {
                            header.add(name: "Authorization", value: "\(strongSelf._user.tokenType ?? "") \(strongSelf._user.authorizationCode ?? "")")
                            let requestb = ServiceHelper.dataRequest(baseURL, method: method, parameters: param, headers: header) { (response) in
                                observer.onNext(response)
                                observer.onCompleted()
                           }
                        }
                        
                    case .failure(_):
                        break
                    }
                }
                
                return Disposables.create{
                    request.cancel()
                }
            }
        }
    }
}
