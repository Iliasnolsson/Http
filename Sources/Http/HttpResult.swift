//
//  PostGetResponse.swift
//  Lotte
//
//  Created by Ilias Nikolaidis Olsson on 2022-06-25.
//

import Foundation

public class HttpResult {
    
    public let succeeded: Bool
    public let message: String
    
    private init(succeeded: Bool, message: String) {
        self.succeeded = succeeded
        self.message = message
    }
    
    static var success: HttpResult {.init(succeeded: true, message: "")}
    
    static func fail(message: String) -> HttpResult {
        return .init(succeeded: false, message: message)
    }
    
}

