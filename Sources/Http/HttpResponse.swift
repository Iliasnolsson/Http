//
//  PostGetResponse.swift
//  Lotte
//
//  Created by Ilias Nikolaidis Olsson on 2022-06-25.
//

import Foundation

public class HttpResponse {
    
    public let succeeded: Bool
    public let message: String
    
    private init(succeeded: Bool, message: String) {
        self.succeeded = succeeded
        self.message = message
    }
    
    static var success: HttpResponse {.init(succeeded: true, message: "")}
    
    static func fail(message: String) -> HttpResponse {
        return .init(succeeded: false, message: message)
    }
    
}
