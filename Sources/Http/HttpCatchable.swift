//
//  HttpCatchable.swift
//  lotte-ios
//
//  Created by Ilias Nikolaidis Olsson on 2022-08-01.
//

import Foundation

open class HttpCatchable: InternalHttpBaseObject {
    
    private func handle<T>(_ sessionMethod: (() async throws -> ((Data, URLResponse)))) async throws -> T where T: Decodable {
        do {
            if let (responseData, response) = (try await sessionMethod()) as? (Data, HTTPURLResponse) {
                if response.statusCode == 200 {
                    return try decoder.decode(T.self, from: responseData)
                }
                throw HttpError.server(statusCode: response.statusCode, message: response.description)
            }
            throw HttpError.server(statusCode: .invalidStatusCode, message: "Bad Server Response")
        } catch let error as HttpError {
            throw error
        } catch is DecodingError {
            throw HttpError.app(.appSideDecodeFailure)
        } catch {
            throw HttpError.transport()
        }
    }
    
}

// MARK: Get
public extension HttpCatchable {
    
    final func get<T: Decodable>(_ urlAddon: String, query: [String : LosslessStringConvertible] = [:]) async throws -> T {
        let request = await getRequest(forUrl: urlForAddon(urlAddon, query: query))
        return try await handle({() in
            return try await session.data(for: request)
        })
    }
    
}

// MARK: Post
public extension HttpCatchable {
    
    final func post(_ urlAddon: String, body: [String : Any]) async throws {
        if (JSONSerialization.isValidJSONObject(body)),
            let data = try? JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted]) {
            try await post(urlAddon, bodyForData: data)
        } else {
            throw HttpError.app(.appSideBodyJsonConversion)
        }
    }
    
    final func post(_ urlAddon: String, bodyForData: Data) async throws {
        let request = await postRequest(forUrl: urlForAddon(urlAddon))
        do {
            if let response = (try await session.upload(for: request, from: bodyForData)).1 as? HTTPURLResponse {
                if response.statusCode != 200 {
                    throw HttpError.server(statusCode: response.statusCode, message: response.description)
                }
            } else {
                throw HttpError.server(statusCode: .invalidStatusCode, message: "Bad Server Response")
            }
        } catch let error as HttpError {
            throw error
        } catch {
            throw HttpError.transport()
        }
    }
    
    final func post<T: Decodable>(_ urlAddon: String, body: [String : Any]) async throws -> T {
        if (JSONSerialization.isValidJSONObject(body)),
            let data = try? JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted]) {
            return try await post(urlAddon, bodyForData: data)
        }
        throw HttpError.app(.appSideBodyJsonConversion)
    }
    
    final func post<T: Decodable>(_ urlAddon: String, bodyForData: Data) async throws -> T {
        let request = await postRequest(forUrl: urlForAddon(urlAddon))
        return try await handle({() in
            return try await session.upload(for: request, from: bodyForData)
        })
    }
    
}

