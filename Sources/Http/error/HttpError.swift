//
//  HttpError.swift
//  lotte-ios
//
//  Created by Ilias Nikolaidis Olsson on 2022-08-01.
//

import Foundation

public struct HttpError: LocalizedError {
    
    public let type: HttpErrorType
    public let statusCode: HttpStatusCode
    public let message: String
    
    private init(type: HttpErrorType, statusCode: HttpStatusCode, message: String) {
        self.type = type
        self.statusCode = statusCode
        self.message = message
    }
    
    static func app(_ type: HttpErrorType) -> HttpError {
        return .init(type: type, statusCode: .invalidStatusCode, message: "")
    }
    
    static func transport() -> HttpError {
        return .init(type: .transport, statusCode: .invalidStatusCode, message: "")
    }
    
    static func server(statusCode: HttpStatusCode, message: String) -> HttpError {
        return .init(type: .serverSide, statusCode: statusCode, message: message)
    }
    
    static func server(statusCode: Int, message: String) -> HttpError {
        return .server(statusCode: .init(rawValue: statusCode) ?? .invalidStatusCode, message: message)
    }
    
}
