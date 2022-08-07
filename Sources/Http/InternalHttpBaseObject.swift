//
//  HttpBase.swift
//  lotte-ios
//
//  Created by Ilias Nikolaidis Olsson on 2022-08-01.
//

import Foundation

/// Do not subclass, please use Http or HttpCatchable instead
open class InternalHttpBaseObject: NSObject {
    
    public let baseUrl: URL
    public let accessTokenBearerName: String
    internal var session = URLSession.shared
    internal let decoder = JSONDecoder()
    internal let encoder = JSONEncoder()
 
    /// Simplifier for http calls to web api
    /// - Parameters:
    ///   - baseUrl: The route url for all posts & gets,  Example:  https://localhost:5001/api
    ///   - bypassInvalidCertificate: Default is False, Enabled calls to servers with invalid certificates, Example: enabled calls to localhost
    ///   - accessTokenBearerName: Default is "Bearer",  starter word in the Http header field for access token.
    public init(baseUrl: URL, bypassInvalidCertificate: Bool = false, accessTokenBearerName: String = "Bearer") {
        self.baseUrl = baseUrl
        self.accessTokenBearerName = accessTokenBearerName
        super.init()
        
        
        if (bypassInvalidCertificate) {
            self.session = .init(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }
    
    open func postRequest(forUrl url: URL) async -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        await addHeaders(to: &request)
        return request
    }
    
    open func getRequest(forUrl url: URL) async -> URLRequest {
        var request = URLRequest(url: url)
        await addHeaders(to: &request)
        return request
    }
    
    // Gets added to URLReqest if not nil
    open func accessToken() async -> String? {
        return nil
    }
    
}

extension InternalHttpBaseObject: URLSessionDelegate {
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
    
}

extension InternalHttpBaseObject {
    
    func urlForAddon(_ addon: String) -> URL {
        if #available(iOS 16.0, *) {
            return baseUrl.appending(path: addon)
        }
        return baseUrl.appendingPathComponent(addon)
    }
    
    func urlForAddon(_ addon: String, query: [String : LosslessStringConvertible]) -> URL {
        var url = urlForAddon(addon)
        var queryItems = [URLQueryItem]()
        for (key, value) in query {
            queryItems.append(.init(name: key, value: value.description))
        }
        if #available(iOS 16.0, *) {
            url.append(queryItems: queryItems)
        }
        return url
    }
    
    func addHeaders(to request: inout URLRequest) async -> Void {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
     
        if let accessToken = await accessToken(), !accessToken.isEmpty {
            addHeaderAccessToken(accessToken, to: &request)
        }
    }
    
    func addHeaderAccessToken(_ token: String, to request: inout URLRequest) {
        request.addValue(accessTokenBearerName + " " + token, forHTTPHeaderField: "Authorization")
    }
    
    
}
