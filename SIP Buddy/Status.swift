//
//  Status.swift
//  SIP Buddy
//
//  Created by Keaton Burleson on 6/20/20.
//  Copyright © 2020 Keaton Burleson. All rights reserved.
//

import Foundation

class Status: CustomDebugStringConvertible {
    
    var name: String
    var raw: String
    var debugDescription: String {
        get {
            return "\(self.name): \(self.raw)"
        }
    }
    
    var isDisabled: Bool {
        get {
            self.raw == "disabled"
        }
        set {
            self.raw = newValue ? "disabled" : "enabled"
        }
    }
    
    init(_ name: Substring, _ raw: Substring) {
        self.name = String(name)
        self.raw = String(raw).replacingOccurrences(of: " ", with: "")
    }
    
}
