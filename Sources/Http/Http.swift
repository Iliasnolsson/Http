//
//  PostGetService.swift
//  Lotte
//
//  Created by Ilias Nikolaidis Olsson on 2022-06-25.
//

import Foundation

public class Http: NSObject {
    
    public let baseUrl: URL
    public let bypassInvalidCertificate: Bool
    private var session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    init(baseUrl: URL, bypassInvalidCertificate: Bool = false) {
        self.baseUrl = baseUrl
        self.bypassInvalidCertificate = bypassInvalidCertificate
        super.init()
        self.session = .init(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    public func postRequest(forUrl url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    public func getRequest(forUrl url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
}

// MARK: Get
public extension Http {
    
    final func get<T: Decodable>(_ urlAddon: String) async -> HttpObjectResponse<T> {
        do {
            let request = getRequest(forUrl: urlForAddon(urlAddon))
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
            else {throw URLError(.badServerResponse)}
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch {
            return .fail(message: "")
        }
    }
    
    final func get<T: Decodable>(_ urlAddon: String, dict: [String : String]) async -> HttpObjectResponse<T> {
        if (JSONSerialization.isValidJSONObject(dict)) {
            if let data = try? JSONSerialization.data(withJSONObject: dict) {
                return await get(urlAddon, data: data)
            }
        }
        return .fail(message: "")
    }

    final func get<T: Decodable>(_ urlAddon: String, data: Data) async -> HttpObjectResponse<T> {
        do {
            var request = getRequest(forUrl: urlForAddon(urlAddon))
            request.httpBody = data
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
            else {throw URLError(.badServerResponse)}
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch {
            return .fail(message: "")
        }
    }
    
}

// MARK: Post
public extension Http {
    
    final func post(_ urlAddon: String, dict: [String : String]) async -> HttpResponse {
        if (JSONSerialization.isValidJSONObject(dict)) {
            if let data = try? JSONSerialization.data(withJSONObject: dict) {
                return await post(urlAddon, data: data)
            }
        }
        return .fail(message: "")
    }
    
    final func post(_ urlAddon: String, data: Data) async -> HttpResponse {
        do {
            let request = postRequest(forUrl: urlForAddon(urlAddon))
            let (_, response) = try await session.upload(for: request, from: data)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
            else {throw URLError(.badServerResponse)}
            return .success
        } catch {
            return .fail(message: "")
        }
    }
    
    final func post<T: Decodable>(_ urlAddon: String, dict: [String : Any]) async -> HttpObjectResponse<T> {
        if (JSONSerialization.isValidJSONObject(dict)) {
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]) {
                return await post(urlAddon, data: data)
            }
        }
        return .fail(message: "")
    }
    
    final func post<T: Decodable>(_ urlAddon: String, data: Data) async -> HttpObjectResponse<T> {
        do {
            var request = postRequest(forUrl: urlForAddon(urlAddon))
            request.httpBody = data
            let (responseData, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {throw URLError(.badServerResponse)}
            let object = try decoder.decode(T.self, from: responseData)
            return .success(object)
        } catch {
            return .fail(message: "")
        }
    }
    
}

extension Http: URLSessionDelegate {
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if bypassInvalidCertificate {
            let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, urlCredential)
        }
    }
    
}


extension Http {
    
    private func urlForAddon(_ addon: String) -> URL {
        if #available(iOS 16.0, *) {
            return baseUrl.appending(path: addon)
        }
        return baseUrl.appendingPathComponent(addon)
    }
    
    
}
