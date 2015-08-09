//
//  HostInformation.swift
//  iOS-Kodi-Remote
//
//  Created by David Rodrigues on 08/08/2015.
//
//

import Foundation

class HostInformation: NSObject, Printable {
    
    var name:String! = "Kodi"
    var address:String! = nil
    var httpPort:Int! = 8080
    var tcpPort:Int! = 9090
    var eventServerPort:Int! = 9777
    
    var domain:String! = "local."
    
    var username:String? = nil
    var password:String? = nil
    
    init(netService:NSNetService!) {
        self.name = netService.name
        self.httpPort = netService.port
        self.domain = netService.domain
        
        if netService.addresses?.count > 0 {
            let firstAddressData:AnyObject? = netService.addresses?.first
            var address_storage = sockaddr_storage()
            
            firstAddressData?.getBytes(&address_storage, length: sizeof(sockaddr_in))
            
            if Int32(address_storage.ss_family) == AF_INET {
                let socketAddress = withUnsafePointer(&address_storage) { UnsafePointer<sockaddr_in>($0).memory }
                
                self.address = String(CString: inet_ntoa(socketAddress.sin_addr), encoding: NSASCIIStringEncoding)
            }
        }
    }
    
    init(name:String!, httpPort:Int!, domain:String!) {
        self.name = name
        self.httpPort = httpPort
        self.domain = domain
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        let other:HostInformation = object as! HostInformation
        return other.name == self.name && other.httpPort == self.httpPort && other.domain == self.domain && other.username == self.username && other.address == self.address
    }
    
    override var description: String {
        return "\(name) - \(address) - \(httpPort)"
    }
}