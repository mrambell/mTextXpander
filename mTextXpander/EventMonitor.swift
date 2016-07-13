//
//  EventMonitor.swift
//  mTextXpander
//
//  Created by Mattia Rambelli (TS-DE) on 05/07/16.
//  Copyright © 2016 rms. All rights reserved.
//

import Foundation
import Cocoa

public class EventMonitor {
    private var monitor: AnyObject?
    private let mask: NSEventMask
    private let handler: NSEvent? -> ()
    
    public init(mask: NSEventMask, handler: NSEvent? -> ()) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    public func start() {
        self.monitor = NSEvent.addGlobalMonitorForEventsMatchingMask(self.mask, handler: self.handler)
    }
    
    public func stop() {
        if self.monitor != nil {
            NSEvent.removeMonitor(self.monitor!)
            self.monitor = nil
        }
    }
}
