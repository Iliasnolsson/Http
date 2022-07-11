//
//  PostGetService.swift
//  Lotte
//
//  Created by Ilias Nikolaidis Olsson on 2022-06-25.
//

import Foundation

open class Http: NSObject {
    
    public let baseUrl: URL
    public let accessTokenBearerName: String
    private var session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
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

// MARK: Get
public extension Http {
    
    final func get<T: Decodable>(_ urlAddon: String) async -> HttpObjectResult<T> {
        do {
            let request = await getRequest(forUrl: urlForAddon(urlAddon))
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
            else {throw URLError(.badServerResponse)}
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch {
            return .fail(message: error.localizedDescription)
        }
    }
    
    final func get<T: Decodable>(_ urlAddon: String, dict: [String : Any]) async -> HttpObjectResult<T> {
        if (JSONSerialization.isValidJSONObject(dict)) {
            if let data = try? JSONSerialization.data(withJSONObject: dict) {
                return await get(urlAddon, data: data)
            }
        }
        return .fail(message: "")
    }

    final func get<T: Decodable>(_ urlAddon: String, data: Data? = nil) async -> HttpObjectResult<T> {
        do {
            var request = await getRequest(forUrl: urlForAddon(urlAddon))
            if let data = data {
                request.httpBody = data
            }
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
            else {throw URLError(.badServerResponse)}
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch {
            return .fail(message: error.localizedDescription)
        }
    }
    
}

// MARK: Post
public extension Http {
    
    final func post(_ urlAddon: String, dict: [String : Any]) async -> HttpResult {
        if (JSONSerialization.isValidJSONObject(dict)) {
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]) {
                return await post(urlAddon, data: data)
            }
        }
        return .fail(message: "")
    }
    
    final func post(_ urlAddon: String, data: Data) async -> HttpResult {
        do {
            let request = await postRequest(forUrl: urlForAddon(urlAddon))
            let (_, response) = try await session.upload(for: request, from: data)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
            else {throw URLError(.badServerResponse)}
            return .success
        } catch {
            return .fail(message: error.localizedDescription)
        }
    }
    
    final func post<T: Decodable>(_ urlAddon: String, dict: [String : Any]) async -> HttpObjectResult<T> {
        if (JSONSerialization.isValidJSONObject(dict)) {
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]) {
                return await post(urlAddon, data: data)
            }
        }
        return .fail(message: "")
    }
    
    final func post<T: Decodable>(_ urlAddon: String, data: Data? = nil) async -> HttpObjectResult<T> {
        do {
            var request = await postRequest(forUrl: urlForAddon(urlAddon))
            if let data = data {
                request.httpBody = data
            }
            let (responseData, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {throw URLError(.badServerResponse)}
            let object = try decoder.decode(T.self, from: responseData)
            return .success(object)
        } catch {
            return .fail(message: error.localizedDescription)
        }
    }
    
}

extension Http: URLSessionDelegate {
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
    
}


extension Http {
    
    private func urlForAddon(_ addon: String) -> URL {
        if #available(iOS 16.0, *) {
            return baseUrl.appending(path: addon)
        }
        return baseUrl.appendingPathComponent(addon)
    }
    
    private func addHeaders(to request: inout URLRequest) async -> Void {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
     
        if let accessToken = await accessToken(), !accessToken.isEmpty {
            addHeaderAccessToken(accessToken, to: &request)
        }
    }
    
    private func addHeaderAccessToken(_ token: String, to request: inout URLRequest) {
        request.addValue(accessTokenBearerName + " " + token, forHTTPHeaderField: "Authorization")
    }
    
    
}

