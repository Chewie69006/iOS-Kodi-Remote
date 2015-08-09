//
//  HostManager.swift
//  iOS-Kodi-Remote
//
//  Created by David Rodrigues on 08/08/2015.
//
//

import UIKit

let DNS_XBMC_SERVICE_NAME = "_xbmc-jsonrpc-h._tcp."
let TIMEOUT = Int64(5 * NSEC_PER_SEC)

class HostManager : NSObject {
    
    static let sharedInstance = HostManager()
    
    let hostFinder:HostFinder = HostFinder()
    
    func searchZeroConfHost(completion: (foundHosts:Array<HostInformation>) -> Void) {
        hostFinder.searchZeroConfHost(completion)
    }
    
    
}

