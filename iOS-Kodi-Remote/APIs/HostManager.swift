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
    
    var completion:(Array<HostInformation>) -> Void = { (array) -> Void in }
    var array:Array<HostInformation> = Array()
    
    var running:Array<NSNetService> = Array()
    
    var searchingServices:Bool = false
    
    func searchZeroConfHost(completion: (foundHosts:Array<HostInformation>) -> Void) {
        self.completion = completion
        
        let netServiceBrowser = NSNetServiceBrowser()
        netServiceBrowser.delegate = self
        
        searchingServices = true
        netServiceBrowser.searchForServicesOfType(DNS_XBMC_SERVICE_NAME, inDomain: "")
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, TIMEOUT), dispatch_get_main_queue(), { () -> Void in
            netServiceBrowser.stop()
        })
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        println("count \(change)")
    }
    
    func checkIfSearchIsFinished() -> Void {
        if running.count == 0 && self.searchingServices {
            completion(array)
        }
    }
}

extension HostManager : NSNetServiceBrowserDelegate {
    
    /* Sent to the NSNetServiceBrowser instance's delegate before the instance begins a search. The delegate will not receive this message if the instance is unable to begin a search. Instead, the delegate will receive the -netServiceBrowser:didNotSearch: message.
    */
    func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        println(__FUNCTION__)
        array = Array()
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when the instance's previous running search request has stopped.
    */
    func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        println(__FUNCTION__)
        checkIfSearchIsFinished()
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when an error in searching for domains or services has occurred. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a search has been started successfully.
    */
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [NSObject : AnyObject]) {
        println("\(__FUNCTION__) \(errorDict)")
        checkIfSearchIsFinished()
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate for each domain discovered. If there are more domains, moreComing will be YES. If for some reason handling discovered domains requires significant processing, accumulating domains until moreComing is NO and then doing the processing in bulk fashion may be desirable.
    */
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        println("\(__FUNCTION__) \(domainString) \(moreComing)")
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate for each service discovered. If there are more services, moreComing will be YES. If for some reason handling discovered services requires significant processing, accumulating services until moreComing is NO and then doing the processing in bulk fashion may be desirable.
    */
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        
        aNetService.delegate = self
        running.append(aNetService)
        aNetService.resolveWithTimeout(5)
        
        println("\(__FUNCTION__) \(aNetService) \(moreComing)")
        
        
        if !moreComing {
            aNetServiceBrowser.stop()
        }
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when a previously discovered domain is no longer available.
    */
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        println("\(__FUNCTION__) \(domainString) \(moreComing)")
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when a previously discovered service is no longer published.
    */
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        // If the net service was trying to resolve an IP address, we stop it
        aNetService.stop()
        
        let hostInformation = HostInformation(netService: aNetService)
        
        println("\(__FUNCTION__) \(hostInformation) \(moreComing)")
        
        array.removeFirst(hostInformation)
    }
    
}

extension HostManager : NSNetServiceDelegate {
    /* Sent to the NSNetService instance's delegate prior to advertising the service on the network. If for some reason the service cannot be published, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotPublish: method.
    */
    func netServiceWillPublish(sender: NSNetService) {
        println(__FUNCTION__)
    }
    
    /* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
    */
    func netServiceDidPublish(sender: NSNetService) {
        println(__FUNCTION__)
    }
    
    /* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
    */
    func netService(sender: NSNetService, didNotPublish errorDict: [NSObject : AnyObject]) {
        println(__FUNCTION__)
    }
    
    /* Sent to the NSNetService instance's delegate prior to resolving a service on the network. If for some reason the resolution cannot occur, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotResolve: method.
    */
    func netServiceWillResolve(sender: NSNetService) {
        println(__FUNCTION__)
    }
    
    /* Sent to the NSNetService instance's delegate when one or more addresses have been resolved for an NSNetService instance. Some NSNetService methods will return different results before and after a successful resolution. An NSNetService instance may get resolved more than once; truly robust clients may wish to resolve again after an error, or to resolve more than once.
    */
    func netServiceDidResolveAddress(sender: NSNetService) {
        println(__FUNCTION__)
        let hostInformation = HostInformation(netService: sender)
        
        array.append(hostInformation)
        removeRunningService(sender)
    }
    
    /* Sent to the NSNetService instance's delegate when an error in resolving the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants).
    */
    func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        println("\(__FUNCTION__) \(sender) \(errorDict)")
        let error: Int = (errorDict[NSNetServicesErrorCode] as! NSNumber).integerValue
        if error == NSNetServicesError.ActivityInProgress.rawValue {
            println("ActivityInProgress")
        } else if error == NSNetServicesError.BadArgumentError.rawValue {
            println("BadArgumentError")
        } else if error == NSNetServicesError.CancelledError.rawValue {
            println("CancelledError")
        } else if error == NSNetServicesError.CollisionError.rawValue {
            println("CollisionError")
        } else if error == NSNetServicesError.InvalidError.rawValue {
            println("InvalidError")
        } else if error == NSNetServicesError.NotFoundError.rawValue {
            println("NotFoundError")
        } else if error == NSNetServicesError.TimeoutError.rawValue {
            println("TimeoutError")
        } else if error == NSNetServicesError.UnknownError.rawValue {
            println("UnknownError")
        }
        sender.stop()
        removeRunningService(sender)
    }
    
    /* Sent to the NSNetService instance's delegate when the instance's previously running publication or resolution request has stopped.
    */
    func netServiceDidStop(sender: NSNetService) {
        println(__FUNCTION__)
        removeRunningService(sender)
    }
    
    /* Sent to the NSNetService instance's delegate when the instance is being monitored and the instance's TXT record has been updated. The new record is contained in the data parameter.
    */
    func netService(sender: NSNetService, didUpdateTXTRecordData data: NSData) {
        println(__FUNCTION__)
    }
    
    func removeRunningService(aNetService: NSNetService) {
        running.removeFirst(aNetService)
        checkIfSearchIsFinished()
    }
}
