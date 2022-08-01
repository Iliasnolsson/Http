//
//  PostGetService.swift
//  Lotte
//
//  Created by Ilias Nikolaidis Olsson on 2022-06-25.
//

import Foundation

open class Http: InternalHttpBaseObject {
    
}

// MARK: Get
public extension Http {
    
    final func get<T: Decodable>(_ urlAddon: String, query: [String : LosslessStringConvertible] = [:]) async -> HttpObjectResult<T> {
        do {
            let request = await getRequest(forUrl: urlForAddon(urlAddon, query: query))
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
    
    final func post(_ urlAddon: String, body: [String : Any]) async -> HttpResult {
        if (JSONSerialization.isValidJSONObject(body)) {
            if let data = try? JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted]) {
                return await post(urlAddon, bodyForData: data)
            }
        }
        return .fail(message: "")
    }
    
    final func post(_ urlAddon: String, bodyForData: Data) async -> HttpResult {
        do {
            let request = await postRequest(forUrl: urlForAddon(urlAddon))
            let (_, response) = try await session.upload(for: request, from: bodyForData)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
            else {throw URLError(.badServerResponse)}
            return .success
        } catch {
            return .fail(message: error.localizedDescription)
        }
    }
    
    final func post<T: Decodable>(_ urlAddon: String, body: [String : Any]) async -> HttpObjectResult<T> {
        if (JSONSerialization.isValidJSONObject(body)) {
            if let data = try? JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted]) {
                return await post(urlAddon, bodyForData: data)
            }
        }
        return .fail(message: "")
    }
    
    final func post<T: Decodable>(_ urlAddon: String, bodyForData: Data) async -> HttpObjectResult<T> {
        do {
            let request = await postRequest(forUrl: urlForAddon(urlAddon))
            let (responseData, response) = try await session.upload(for: request, from: bodyForData)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {throw URLError(.badServerResponse)}
            let object = try decoder.decode(T.self, from: responseData)
            return .success(object)
        } catch {
            return .fail(message: error.localizedDescription)
        }
    }
    
}

