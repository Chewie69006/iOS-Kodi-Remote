//
//  ViewController.swift
//  iOS-Kodi-Remote
//
//  Created by David Rodrigues on 08/08/2015.
//
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let hostManager = HostManager.sharedInstance
        hostManager.searchZeroConfHost { (foundHosts) -> Void in
            println("\(foundHosts)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

