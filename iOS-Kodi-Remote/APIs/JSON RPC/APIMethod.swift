//
//  APIMethod.swift
//  iOS-Kodi-Remote
//
//  Created by David Rodrigues on 8/12/15.
//
//

import UIKit

class APIMethod {
    internal let resultNode = "result"
    internal let errorNode = "error"
    internal let identifierNode = "identifier"
    internal let methodNode = "method"
    internal let parametersNode = "params"
    
    private static var lastIdentifier:Int = 0
    private let identifier:Int
    
    internal var JSONRequest:NSDictionary!
    
    init() {
        self.identifier = ++APIMethod.lastIdentifier % 10000
    
        JSONRequest = [
            "jsonrpc": "2.0",
            methodNode: self.getMethodName(),
            identifierNode: self.identifierNode]
    }
    
    func getMethodName() -> String {
        return ""
    }
    
}


