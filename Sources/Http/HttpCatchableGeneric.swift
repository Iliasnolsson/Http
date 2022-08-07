//
//  File.swift
//  
//
//  Created by Ilias Nikolaidis Olsson on 2022-08-07.
//

import Foundation

open class HttpCatchableGeneric<S: HttpEndpoint>: HttpCatchable {
    
    
    
    
}

// MARK: Get
public extension HttpCatchableGeneric {
    
    final func get<T: Decodable>(_ urlAddon: S, query: [String : LosslessStringConvertible] = [:]) async throws -> T {
        return try await get(urlAddon.rawValue, query: query)
    }
    
}

// MARK: Post
public extension HttpCatchableGeneric {
    
    final func post(_ urlAddon: S, body: [String : Any]) async throws {
        return try await post(urlAddon.rawValue, body: body)
    }
    
    final func post(_ urlAddon: S, bodyForData: Data) async throws {
        return try await post(urlAddon.rawValue, bodyForData: bodyForData)
    }
    
    final func post<T: Decodable>(_ urlAddon: S, body: [String : Any]) async throws -> T {
        return try await post(urlAddon.rawValue, body: body)
    }
    
    final func post<T: Decodable>(_ urlAddon: S, bodyForData: Data) async throws -> T {
        return try await post(urlAddon.rawValue, bodyForData: bodyForData)
    }
    
}
