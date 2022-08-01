//
//  HttpErrorType.swift
//  lotte-ios
//
//  Created by Ilias Nikolaidis Olsson on 2022-08-01.
//

import Foundation

public enum HttpErrorType: Int {
    
    /// Http call did not reach server, check console for transport issue
    case transport = 5
    
    /// Http call reach server but server responded with some sort of fail
    case serverSide = 10
    
    /// Body cannot be converted into json
    case appSideBodyJsonConversion = 15
    
    /// Was not able to decode data from server into desired Decodable
    case appSideDecodeFailure = 20
    
}
