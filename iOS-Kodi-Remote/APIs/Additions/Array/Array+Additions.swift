//
//  Array+Additions.swift
//  iOS-Kodi-Remote
//
//  Created by David Rodrigues on 08/08/2015.
//
//

import Foundation

extension Array {
    mutating func removeFirst(element: Element, equality: (Element, Element) -> Bool) -> Bool {
        for (index, item) in enumerate(self) {
            if equality(item, element) {
                self.removeAtIndex(index)
                return true
            }
        }
        return false
    }
    
    mutating func removeFirst(element: AnyObject) -> Bool {
        for (index, item) in enumerate(self) {
            let itemObject:AnyObject = item as! AnyObject
            if element.isEqual(itemObject) {
                self.removeAtIndex(index)
                return true
            }
        }
        return false

    }
}