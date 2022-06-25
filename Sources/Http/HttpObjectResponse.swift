//
//  PostGetObjectResponse.swift
//  Lotte
//
//  Created by Ilias Nikolaidis Olsson on 2022-06-25.
//

import Foundation

public class HttpObjectResponse<T> {
    
    public let object: T!
    public let succeeded: Bool
    public let message: String
    
    private init(object: T?, succeeded: Bool, message: String) {
        self.object = object
        self.succeeded = succeeded
        self.message = message
    }
    
    static func success(_ object: T) -> HttpObjectResponse {
        return .init(object: object, succeeded: true, message: "")
    }
    
    static func fail(message: String) -> HttpObjectResponse {
        return .init(object: nil, succeeded: false, message: message)
    }
    
}
